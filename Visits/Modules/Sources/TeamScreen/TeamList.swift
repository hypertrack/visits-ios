
import NonEmpty
import SwiftUI
import Types
import PlacesScreen

struct TeamList: View {
    let teamWorkers: [WorkerHandle]

//    var navigationLink: NavigationLink<EmptyView, VisitScreen>? {
//        guard let visit = selected else { return nil }
//
//        return NavigationLink(
//            destination: VisitScreen(
//                state: .init(visit: visit),
//                copy: copy
//            ),
//            tag: visit,
//            selection: .init(
//                get: { selected },
//                set: { select($0) }
//            )
//        ) {
//            EmptyView()
//        }
//    }

    var body: some View {
        ZStack {
//            navigationLink
            List {
                ForEach(teamWorkers, id: \.self) { teamWorker in
                    Text(teamWorker.rawValue.rawValue)
                }
            }
            if teamWorkers.isEmpty {
                Text("No team")
                    .font(.title)
                    .foregroundColor(Color(.secondaryLabel))
                    .fontWeight(.bold)
            }
        }
        .navigationBarTitle(Text("Team"), displayMode: .automatic)
    }
}
