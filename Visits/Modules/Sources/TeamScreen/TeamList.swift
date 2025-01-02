
import NonEmpty
import SwiftUI
import Types

struct TeamList: View {
    let select: (WorkerHandle) -> Void
    let teamWorkers: [WorkerHandle]

    var body: some View {
        ZStack {
            List {
                ForEach(teamWorkers, id: \.self) { teamWorker in
                    Button {
                        select(teamWorker)
                    } label: {
                        Text(teamWorker.rawValue.rawValue)
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
