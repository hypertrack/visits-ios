import ComposableArchitecture
import SwiftUI
import Types
import Views


struct ChoosingCoordinateView: View {
  struct State: Equatable {
    var coordinate: Coordinate?
    var places: Set<Place>
  }
  enum Action {
    case cancelAddPlace
    case updatedAddPlaceCoordinate(Coordinate)
    case confirmAddPlaceCoordinate
    case selectedPlace(Place)
  }
  
  
  let store: Store<State, Action>
  init(store: Store<State, Action>) { self.store = store }
  
  var body: some View {
    GeometryReader { geometry in
      WithViewStore(store) { viewStore in
        ZStack {
          PlaceMapView(
            inputCoordinateForSearch: .init(
              get: {
                viewStore.coordinate?.coordinate2D
              },
              set: {
                if let c = $0 {
                  viewStore.send(.updatedAddPlaceCoordinate(Coordinate(coordinate2D: c)!))
                }
              }
            ),
            places: viewStore.places,
            sendSelectedPlace: {
              viewStore.send(.selectedPlace($0))
            }
          )
          HStack {
            VStack {
              Button(action: { viewStore.send(.cancelAddPlace) }) {
                Image(systemName: "arrow.backward")
              }
              .foregroundColor(.accentColor)
              .frame(width: 40, height: 40)
              .background(Color(.systemBackground))
              .clipShape(RoundedRectangle(cornerRadius: 8))
              .padding(.leading, 16)
              .padding(.top, 48)
              Spacer()
            }
            Spacer()
          }
          VStack {
            Spacer()
            PrimaryButton(variant: .normal(title: "Confirm")) {
              viewStore.send(.confirmAddPlaceCoordinate)
            }
            .padding([.trailing, .leading], 64)
            .padding(
              .bottom,
              geometry.safeAreaInsets.bottom > 0 ? geometry.safeAreaInsets
                .bottom : 24
            )
          }
        }
        .edgesIgnoringSafeArea(.all)
      }
    }
  }
}
