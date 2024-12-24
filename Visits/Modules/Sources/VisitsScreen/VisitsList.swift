
import NonEmpty
import SwiftUI
import Types


struct VisitsList: View {
    let visitsToDisplay: [PlaceVisit]
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
                    VisitView.init(visit: visit)
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

public func safeAbsoluteDuration(from: Date, to: Date) -> UInt {
  UInt(abs(from.timeIntervalSince(to)))
}
