import MapDetailView
import NonEmpty
import SwiftUI
import Types
import Views

struct VisitScreen: View {
    struct State {
        let visit: NonEmptyString
    }

    let state: State
    let copy: (NonEmptyString) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // MapDetailView(object: .place(state.place))
                //     .frame(height: 250)
                //     .onTapGesture(perform: { mapTapped(state.place.shape.centerCoordinate, state.place.address) })
                ContentCell(
                    title: "ID",
                    subTitle: state.visit.rawValue,
                    leadingPadding: 24,
                    isCopyButtonEnabled: true,
                    {
                        if let ns = NonEmptyString(rawValue: $0) {
                            copy(ns)
                        }
                    }
                )
                .padding(.top, 8)
                // if let address = state.place.address.anyAddressFullBias?.rawValue {
                //     ContentCell(
                //         title: "Location",
                //         subTitle: address,
                //         leadingPadding: 24,
                //         isCopyButtonEnabled: true,
                //         {
                //             if let ns = NonEmptyString(rawValue: $0) {
                //                 copy(ns)
                //             }
                //         }
                //     )
                //     .padding(.top, 8)
                // }
                // ForEach(state.place.metadata.sorted(by: { $0.0 < $1.0 }), id: \.key) { name, contents in
                //     ContentCell(
                //         title: name.string
                //             .capitalized
                //             .replacingOccurrences(of: "_", with: " "),
                //         subTitle: contents.string,
                //         leadingPadding: 24,
                //         isCopyButtonEnabled: true,
                //         {
                //             if let ns = NonEmptyString(rawValue: $0) {
                //                 copy(ns)
                //             }
                //         }
                //     )
                // }
                // .padding(.top, 8)
                // if let entry = state.place.currentlyInside {
                //     VisitView(
                //         id: entry.id.rawValue,
                //         entry: entry.entry.rawValue,
                //         exit: nil,
                //         duration: safeAbsoluteDuration(from: entry.entry.rawValue, to: Date()),
                //         copy: copy
                //     )
                //     .padding(.horizontal)
                //     .padding(.top)
                //     if let route = entry.route {
                //         RouteView(
                //             distance: route.distance.rawValue,
                //             duration: route.duration.rawValue,
                //             idleTime: route.idleTime.rawValue
                //         )
                //         .padding(.horizontal)
                //         .padding(.top)
                //     }
                // }
                // ForEach(state.place.visits) { visit in
                //     VisitView(
                //         id: visit.id.rawValue,
                //         entry: visit.entry.rawValue,
                //         exit: visit.exit.rawValue,
                //         duration: safeAbsoluteDuration(from: visit.entry.rawValue, to: visit.exit.rawValue),
                //         copy: copy
                //     )
                //     .padding(.horizontal)
                //     .padding(.top)
                //     if let route = visit.route {
                //         RouteView(
                //             distance: route.distance.rawValue,
                //             duration: route.duration.rawValue,
                //             idleTime: route.idleTime.rawValue
                //         )
                //         .padding(.horizontal)
                //         .padding(.top)
                //     }
                // }

                Spacer()
            }
        }
        // .navigationBarTitle(Text(state.place.name?.rawValue ?? state.place.fallbackTitle.rawValue), displayMode: .inline)
        .navigationBarTitle(Text(state.visit.rawValue), displayMode: .inline)
    }
}

// struct PlaceScreen_Previews: PreviewProvider {
//     static var previews: some View {
//         PlaceScreen(
//             state: .init(
//                 place: placePreviewSample
//             ),
//             copy: { _ in },
//             mapTapped: { _, _ in }
//         )
//         .preferredColorScheme(.dark)
//     }
// }

// func safeAbsoluteDuration(from: Date, to: Date) -> UInt {
//     UInt(abs(from.timeIntervalSince(to)))
// }
