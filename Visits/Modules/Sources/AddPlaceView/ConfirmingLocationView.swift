import ComposableArchitecture
import MapKit
import NonEmpty
import SwiftUI
import Types
import Views


struct ConfirmingLocationView: View {
  struct State: Equatable {
    var selectedResult: LocalSearchCompletion
    var locations: NonEmptyArray<MapPlace>
  }
  enum Action {
    case cancelConfirmingLocation
    case confirmAddPlaceLocation(MapPlace)
  }
  
  let store: Store<State, Action>
  init(store: Store<State, Action>) { self.store = store }
  
  var body: some View {
    GeometryReader { geometry in
      WithViewStore(store) { viewStore in
        VStack(spacing: 0) {
          VStack(spacing: 0) {
            TopPadding(geometry: geometry)
            Header(
              title: "Confirm Location",
              backAction: { viewStore.send(.cancelConfirmingLocation) },
              refreshing: false
            )
          }
          List {
            ForEach(viewStore.locations, id: \.hashValue) { mapPlace in
              Button {
                viewStore.send(.confirmAddPlaceLocation(mapPlace))
              } label: {
                MapPlaceView(mapPlace: mapPlace)
              }
            }
          }
        }
        .edgesIgnoringSafeArea(.top)
      }
    }
  }
}

struct MapPlaceView: View {
  let mapPlace: MapPlace
  
  var body: some View {
    VStack {
      Map(
        coordinateRegion: .constant(
          .init(
            center: mapPlace.location.coordinate2D,
            latitudinalMeters: 500,
            longitudinalMeters: 500
          )
        ),
        interactionModes: [],
        showsUserLocation: true,
        userTrackingMode: .constant(.none),
        annotationItems: [mapPlace.location.coordinate2D],
        annotationContent: { c in MapPin(coordinate: c) }
      )
      .frame(height: 200)
      .cornerRadius(10)
      if let name = mapPlace.name {
        PrimaryRow(name.string)
          .padding(.bottom, -3)
      }
      if let full = mapPlace.address.fullAddress {
        SecondaryRow(full.string)
      }
    }
    .padding()
  }
}

extension CLLocationCoordinate2D: Identifiable {
  public var id: String { "\(latitude)-\(longitude)" }
}
