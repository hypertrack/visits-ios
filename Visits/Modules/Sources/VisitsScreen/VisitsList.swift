
import NonEmpty
import SwiftUI
import Types


struct VisitsList: View {
    let visitsToDisplay: [PlaceVisit]
    let selected: PlaceVisit?
    let select: (PlaceVisit?) -> Void
    let copy: (NonEmptyString) -> Void

    var navigationLink: NavigationLink<EmptyView, VisitScreen>? {
        guard let visit = selected else { return nil }

        return NavigationLink(
            destination: VisitScreen(
                state: .init(visit: visit),
                copy: copy
            ),
            tag: visit,
            selection: .init(
                get: { selected },
                set: { select($0) }
            )
        ) {
            EmptyView()
        }
    }

    var body: some View {
        let dayToVisitsMap = Dictionary(grouping: visitsToDisplay, by: { $0.entry })

        ZStack {
            navigationLink
            List {
                ForEach(dayToVisitsMap.keys.sorted(by: >), id: \.self) { day in
                    Section(header: Text("\(DateFormatter.stringDate(day.rawValue))")) {
                        ForEach(dayToVisitsMap[day]!, id: \.id) { visit in
                            VisitView(
                                onClick: {
                                    select(visit)
                                },
                                visit: visit
                            )
                            .padding()
                        }
                    }
                }
            }
           .listStyle(GroupedListStyle())
            if visitsToDisplay.isEmpty {
                Text("No visits yet")
                    .font(.title)
                    .foregroundColor(Color(.secondaryLabel))
                    .fontWeight(.bold)
            }
        }
    }
}

public func safeAbsoluteDuration(from: Date, to: Date) -> UInt {
  UInt(abs(from.timeIntervalSince(to)))
}
