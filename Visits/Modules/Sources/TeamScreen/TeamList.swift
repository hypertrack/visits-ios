
import NonEmpty
import SwiftUI
import Types

struct TeamList: View {
    let select: (WorkerHandle) -> Void
    let teamWorkers: [TeamValue]

    var body: some View {
        ZStack {
            List {
                ForEach(teamWorkers) { teamWorker in
                    switch teamWorker {
                    case let .l0Worker(worker):
                        Button {
                            select(worker.workerHandle)
                        } label: {
                            Text(worker.workerHandle.rawValue.rawValue)
                        }.padding(.leading, 16)
                    case let .l1Manager(manager):
                        Button {
                            select(manager.workerHandle)
                        } label: {
                            Text(manager.workerHandle.rawValue.rawValue)
                        }
                    default:
                        // this should not be possible
                        Text("Unknown worker")
                    }
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
