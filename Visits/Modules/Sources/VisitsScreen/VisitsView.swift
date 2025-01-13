
import NonEmpty
import SwiftUI
import Types
import Views
import Utility
import PlacesScreen

public struct VisitsView: View {
    public struct ScreenState {
        let from: Date
        let refreshing: Bool
        let selected: PlaceVisit?
        let to: Date
        let visits: VisitsData?
        let workerHandle: WorkerHandle

        public init(
            from: Date,
            refreshing: Bool,
            selected: PlaceVisit?,
            to: Date,
            visits: VisitsData?,
            workerHandle: WorkerHandle
        ) {
            self.from = from
            self.refreshing = refreshing
            self.selected = selected
            self.to = to
            self.visits = visits
            self.workerHandle = workerHandle
        }
    }

    public enum Action: Equatable {
        case copyToPasteboard(NonEmptyString)
        case selectVisit(PlaceVisit?)
        case loadVisits(from: Date, to: Date, WorkerHandle)
    }

    let isForTeam: Bool
    let state: ScreenState
    let send: (Action) -> Void

    @State private var fromDate: Date? = nil
    @State private var toDate: Date? = nil
    @State private var showFromDatePicker: Bool = false
    @State private var showToDatePicker: Bool = false
    @State private var validationError: DatesValidationError? = nil

     private var from: Date {
         fromDate ?? state.from
     }

     private var to: Date {
         toDate ?? state.to
     }

    let calendar = Calendar.current

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }

    public init(
        isForTeam: Bool,
        state: ScreenState,
        send: @escaping (Action) -> Void
    ) {
        self.isForTeam = isForTeam
        self.state = state
        self.send = send
    }

    public var body: some View {
        let fromBinding = Binding<Date>(
            get: { fromDate ?? state.from },
            set: { fromDate = $0 }
        )

        let toBinding = Binding<Date>(
            get: { toDate ?? state.to },
            set: { toDate = $0 }
        )
        return VStack {
            HStack {
                Button(action: {
                    if !self.state.refreshing {
                        showFromDatePicker.toggle()
                    }
                }) {
                    VStack {
                        Text("From")
                            .font(.normalHighBold)
                        Text("\(self.validationError == nil ? self.state.from : fromBinding.wrappedValue, formatter: dateFormatter)")
                            .foregroundColor(.primary)
                    }
                }.padding(.horizontal, 16)

                Spacer()

                Button(action: {
                    if !self.state.refreshing {
                        showToDatePicker.toggle()
                    }
                }
                ) {
                    VStack {
                        Text("To")
                            .font(.normalHighBold)
                        Text("\(self.validationError == nil ? self.state.to : toBinding.wrappedValue, formatter: dateFormatter)")
                            .foregroundColor(.primary)
                    }
                }.padding(.horizontal, 16)
            }

            let navigationBarTitle = isForTeam
                ? Text(state.workerHandle.rawValue.rawValue).font(.smallMedium)
                : Text("Visits")

            VStack {
                if let visits = state.visits, validationError == nil {
                    HStack {
                        VStack {
                            Text("\(visits.summary.visitsNumber)")
                                .font(.callout)
                                .foregroundColor(.secondary)
                            Text("Visits")
                                .font(.tinyMedium)
                        }
                        Spacer()
                        VStack {
                            Text("\(visits.summary.visitedPlacesNumber)")
                                .font(.callout)
                                .foregroundColor(.secondary)
                            Text("Places")
                                .font(.tinyMedium)
                        }
                        Spacer()
                        VStack {
                            Text("\(localizedTime(visits.summary.timeSpentInsideGeofences, style: .full))")
                                .font(.callout)
                                .foregroundColor(.secondary)
                            Text("Spent")
                                .font(.tinyMedium)
                        }
                        Spacer()
                        VStack {
                            Text("\(localizedDistance(visits.summary.totalDriveDistance))")
                                .font(.callout)
                                .foregroundColor(.secondary)
                            Text("Traveled")
                                .font(.tinyMedium)
                        }
                    }
                    .padding(.top, 8)
                    .padding(.horizontal, 16)

                    VisitsList(
                        visitsToDisplay: state.visits?.visits ?? [], selected: state.selected,
                        select: { visit in
                            send(.selectVisit(visit))
                        },
                        copy: { id in
                            send(.copyToPasteboard(id))
                        }
                    )
                } else {
                    Spacer()
                    Text(getErrorText()).padding(16)
                    Spacer()
                }
            }
            .navigationBarTitle(navigationBarTitle, displayMode: .inline)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                RefreshButton(state: self.state.refreshing ? .refreshing : .enabled) {
                    send(.loadVisits(
                        from: getRangeStartFromDate(self.state.from, Calendar.current, TimeZone.current), 
                        to: getRangeEndFromDate(self.state.to, Calendar.current, TimeZone.current),
                        self.state.workerHandle
                        ))
                }
            }
        }
        .sheet(isPresented: $showFromDatePicker, onDismiss: {
            onFromChanged()
        }) {
            VStack {
                Text("From date:")
                    .font(.title)
                DatePicker("From", selection: fromBinding, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()
                Button("Select") {
                    showFromDatePicker.toggle()
                    onFromChanged()
                }
            }
        }
        .sheet(isPresented: $showToDatePicker, onDismiss: {
            onToChanged()
        }) {
            VStack {
                Text("To date:")
                    .font(.title)
                DatePicker("To", selection: toBinding, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()
                Button("Select") {
                    showToDatePicker.toggle()
                    onToChanged()
                }
            }
        }
    }

    func onFromChanged() {
        let result = validate(settingFrom: true, from: from, to: to)
        switch result {
        case .success:
            validationError = nil
            send(.loadVisits(
                from: getRangeStartFromDate(from, Calendar.current, TimeZone.current),
                to: getRangeEndFromDate(to, Calendar.current, TimeZone.current),
                self.state.workerHandle
                ))
        case let .failure(error):
            validationError = error
        }
    }

    func onToChanged() {
        let result = validate(settingFrom: false, from: from, to: to)
        switch result {
        case .success:
            validationError = nil
            send(.loadVisits(
                from: getRangeStartFromDate(from, Calendar.current, TimeZone.current),
                to: getRangeEndFromDate(to, Calendar.current, TimeZone.current),
                self.state.workerHandle
                ))
        case let .failure(error):
            validationError = error
        }
    }

    func getErrorText() -> String {
        switch validationError {
        case .fromInTheFuture:
            return "`From` date cannot be in the future"
        case .toInTheFuture:
            return "`To` date cannot be in the future"
        case .fromDateAfterToDate:
            return "`From` date cannot be after `To` date"
        case .toDateBeforeFromDate:
            return "`To` date cannot be before `From` date"
        case .rangeIsTooBig:
            return "Date range is too big. Maximum allowed range is 31 days"
        case .none:
            return ""
        }
    }

    enum DatesValidationError: Error {
        case fromInTheFuture
        case toInTheFuture
        case fromDateAfterToDate
        case toDateBeforeFromDate
        case rangeIsTooBig
    }

    let MAX_HISTORY_RANGE_DAYS = 31

    func validate(
        settingFrom: Bool,
        from fromRaw: Date,
        to toRaw: Date
    ) -> Result<Void, DatesValidationError> {
        let now = Date()
        let from = calendar.startOfDay(for: fromRaw)
        let to = calendar.startOfDay(for: toRaw)

        // Check if 'from' is in the future
        if from > now {
            return settingFrom
                ? .failure(.fromInTheFuture)
                : .failure(.toInTheFuture)
        }

        // Check if 'to' is in the future
        if to > now {
            return settingFrom
                ? .failure(.fromInTheFuture)
                : .failure(.toInTheFuture)
        }

        // Check if 'from' is after 'to'
        if from > to {
            return settingFrom
                ? .failure(.fromDateAfterToDate)
                : .failure(.toDateBeforeFromDate)
        }

        // Check if the date range exceeds maximum allowed days
        if let daysBetween = calendar.dateComponents([.day], from: from, to: to).day,
       daysBetween > MAX_HISTORY_RANGE_DAYS {
            return .failure(.rangeIsTooBig)
        }

        // If all checks pass
        return .success(())
    }
}

