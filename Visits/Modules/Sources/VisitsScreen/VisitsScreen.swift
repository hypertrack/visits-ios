import NonEmpty
import SwiftUI
import Types
import Views

public struct VisitsScreen: View {
  public struct ScreenState {
    let from: Date
    let refreshing: Bool
    let selected: PlaceVisit?
    let to: Date
    let visits: VisitsData?

    public init(
      from: Date,
      refreshing: Bool,
      selected: PlaceVisit?,
      to: Date,
      visits: VisitsData?
    ) {
      self.from = from
      self.refreshing = refreshing
      self.selected = selected
      self.to = to
      self.visits = visits
    }
  }

  public enum Action: Equatable {
    case copyToPasteboard(NonEmptyString)
    case selectVisit(PlaceVisit?)
    case loadVisits(from: Date, to: Date)
  }

  let state: ScreenState
  let send: (Action) -> Void

  @State private var fromDate = Date()
  @State private var toDate = Date()
  @State private var showFromDatePicker: Bool = false
  @State private var showToDatePicker: Bool = false
  @State private var validationError: DatesValidationError? = nil

  let calendar = Calendar.current

  private var dateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d"
    return formatter
  }

  public init(
    state: ScreenState,
    send: @escaping (Action) -> Void
  ) {
    self.state = state
    self.send = send
  }

  public var body: some View {
    NavigationView {
      VStack {
        HStack {
          Button(action: {
            if !self.state.refreshing {
              showFromDatePicker.toggle()
            }
          }) {
            VStack {
              Text("From")
                .font(.normalHighBold)
              Text("\(self.validationError == nil ? self.state.from : self.fromDate, formatter: dateFormatter)")
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
              Text("\(self.validationError == nil ? self.state.to : self.toDate, formatter: dateFormatter)")
                .foregroundColor(.primary)
            }
          }.padding(.horizontal, 16)
        }
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
                Text("\(visits.summary.timeSpentInsideGeofences)")
                    .font(.callout)
                    .foregroundColor(.secondary)
                Text("Spent")
                  .font(.tinyMedium)
              }
              Spacer()
              VStack {
                Text("\(visits.summary.totalDriveDistance)")
                    .font(.callout)
                    .foregroundColor(.secondary)
                Text("Traveled")
                  .font(.tinyMedium)
              }
            }
              .padding(.top, 8)
              .padding(.horizontal, 16)
            VisitsList(
              visitsToDisplay: state.visits?.visits ?? [],
              selected: state.selected,
              select: { visit in
                send(.selectVisit(visit))
              },
              copy: { _ in }
            )
          } else {
            Spacer()
            Text(getErrorText())
            Spacer()
          }
        }
        .navigationBarTitle(Text("Visits"), displayMode: .automatic)
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          RefreshButton(state: self.state.refreshing ? .refreshing : .enabled) {
            send(.loadVisits(from: self.state.from, to: self.state.to))
          }
        }
      }
      .sheet(isPresented: $showFromDatePicker, onDismiss: {
        onFromChanged()
      }) {
        VStack {
          Text("From date:")
            .font(.title)
          DatePicker("From", selection: $fromDate, displayedComponents: .date)
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
          DatePicker("To", selection: $toDate, displayedComponents: .date)
            .datePickerStyle(GraphicalDatePickerStyle())
            .padding()
          Button("Select") {
            showToDatePicker.toggle()
            onToChanged()
          }
        }
      }
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }

  func onFromChanged() {
    let result = validate(settingFrom: true, from: fromDate, to: toDate)
    switch result {
    case .success:
      validationError = nil
      send(.loadVisits(from: fromDate, to: toDate))
    case let .failure(error):
      validationError = error
    }
  }

  func onToChanged() {
    let result = validate(settingFrom: false, from: fromDate, to: toDate)
    switch result {
    case .success:
      validationError = nil
      send(.loadVisits(from: fromDate, to: toDate))
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
       daysBetween > MAX_HISTORY_RANGE_DAYS
    {
      return .failure(.rangeIsTooBig)
    }

    // If all checks pass
    return .success(())
  }
}
