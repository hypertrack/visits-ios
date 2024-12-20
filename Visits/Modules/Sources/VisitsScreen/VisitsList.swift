
import NonEmpty
import SwiftUI
import Types
import PlacesScreen

struct VisitsList: View {
    let visitsToDisplay: [Place.Visit]
    let selected: NonEmptyString?
    let select: (NonEmptyString?) -> Void
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
        ZStack {
            navigationLink
            List {
                ForEach(visitsToDisplay, id: \.id) { visit in
                    VisitView.init(
                      id: visit.id.rawValue,
                      entry: visit.entry.rawValue,
                      exit: visit.exit.rawValue,
                      duration: safeAbsoluteDuration(from: visit.entry.rawValue, to: visit.exit.rawValue),
                      copy: copy
                    )
                    .padding()
                }
            }
//            .listStyle(GroupedListStyle())
            if visitsToDisplay.isEmpty {
                Text("No visits yet")
                    .font(.title)
                    .foregroundColor(Color(.secondaryLabel))
                    .fontWeight(.bold)
            }
        }
    }
}

//struct VisitItemView: View {
//    let item: VisitItem
//    let copy: (NonEmptyString) -> Void
//
//    var body: some View {
//        VStack {
//            PlaceView(
//                placeAndTime: .init(
//                    place: item.place,
//                    time: nil
//                ),
//                showNumberOfVisits: false
//            )
//            switch item.entryOrVisit {
//            case let .entry(entry):
//                VisitView(
//                    id: entry.id.rawValue,
//                    entry: entry.entry.rawValue,
//                    exit: nil,
//                    duration: safeAbsoluteDuration(from: entry.entry.rawValue, to: Date()),
//                    copy: copy
//                )
//                .padding()
//                if let route = entry.route {
//                    RouteView(
//                        distance: route.distance.rawValue,
//                        duration: route.duration.rawValue,
//                        idleTime: route.idleTime.rawValue
//                    )
//                    .padding(.horizontal)
//                    .padding(.bottom)
//                }
//            case let .visit(visit):
//                VisitView(
//                    id: visit.id.rawValue,
//                    entry: visit.entry.rawValue,
//                    exit: visit.exit.rawValue,
//                    duration: safeAbsoluteDuration(from: visit.entry.rawValue, to: visit.exit.rawValue),
//                    copy: copy
//                )
//                .padding()
//                if let route = visit.route {
//                    RouteView(
//                        distance: route.distance.rawValue,
//                        duration: route.duration.rawValue,
//                        idleTime: route.idleTime.rawValue
//                    )
//                    .padding(.horizontal)
//                    .padding(.bottom)
//                }
//            }
//        }
//    }
//}
