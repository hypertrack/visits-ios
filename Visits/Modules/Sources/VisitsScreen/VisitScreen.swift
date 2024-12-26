import MapDetailView
import NonEmpty
import SwiftUI
import Types
import Views
import PlacesScreen

struct VisitScreen: View {
    struct State {
        let visit: PlaceVisit
    }

    let state: State
    let copy: (NonEmptyString) -> Void

    var body: some View {
        let visit = state.visit
        ScrollView {
            VStack {
               Text(entryExitTime(entry: visit.entry.rawValue, exit: visit.exit?.rawValue))
                       .font(.callout)
                       .fixedSize(horizontal: false, vertical: true)
                       .frame(maxWidth: .infinity, alignment: .leading)
                       .foregroundColor(Color(.label))
                       .padding(.bottom, 8)
                       .padding(.horizontal, 8)

                let name = visit.name?.rawValue
                if let name = name {
                    Text(name)
                        .font(.headline)
                        .foregroundColor(Color(.label))
                        .padding(.bottom, 8)
                }
                
                let address = visit.address?.rawValue
                if let address = address, address != visit.name?.rawValue {
                    Text(address)
                        .font(.callout)
                        .foregroundColor(Color(.label))
                        .padding(.bottom, 8)
                }
            
                HStack {
                    if visit.duration != 0 {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(Color(.secondaryLabel))
                            VStack(alignment: .leading) {
                                Text(localizedTime(visit.duration, style: .full))
                                    .font(.headline)
                                    .foregroundColor(Color(.secondaryLabel))
                                Text("Spent at the place")
                                    .font(.callout)
                            }
                        }
                    }
                    if visit.route != nil {
                        HStack {
                            Image(systemName: "app.connected.to.app.below.fill")
                                .foregroundColor(Color(.secondaryLabel))
                            VStack(alignment: .leading) {
                            Text("\(localizedDistance(visit.route!.distance.rawValue))")
                                .font(.headline)
                                .foregroundColor(Color(.secondaryLabel))
                            Text("\(localizedTime(visit.route!.duration.rawValue, style: .full))")
                                .font(.callout)
                            }
                        }
                    }
                }

                Divider()
                    .background(Color.gray)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text(visit.id.rawValue.rawValue)
                            .font(.tinyMedium)
                            .foregroundColor(.secondary)
                        
                        Text("Visit ID")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                    
                    Button(action: {
                        UIPasteboard.general.string = visit.id.rawValue.rawValue
                    }) {
                        HStack {
                            Image(systemName: "doc.on.doc")
                                .padding(8)
                        }
                        .font(.body)
                        .foregroundColor(.secondary)
                    }
                }
            }.clipShape(RoundedRectangle(cornerRadius: 8))
        }.navigationTitle("Visit")
    }
}
