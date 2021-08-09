import ComposableArchitecture
import SwiftUI
import Types
import Views


struct ChoosingCoordinateView: View {
  struct State: Equatable {
    var geocoded: GeocodedResult?
    var places: Set<Place>
  }
  enum Action {
    case cancelAddPlace
    case liftedAddPlaceCoordinatePin
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
          VStack(spacing: 0) {
            VStack(spacing: 0) {
              Rectangle()
                .fill(Color.clear)
                .frame(
                  height: geometry.safeAreaInsets.top > 0 ? geometry
                    .safeAreaInsets.top : 20
                )
              HStack {
                Button(action: { viewStore.send(.cancelAddPlace) }) {
                  Image(systemName: "arrow.backward")
                    .padding(.leading, 16)
                }
                Spacer()
                Text("Add place")
                  .padding(.top, 0)
                  .offset(x: -16)
                  .font(.headline)
                  .foregroundColor(Color(.label))
                Spacer()
              }
              .frame(height: 24)
              .padding(.top, 8)
              HStack {
                ZStack {
                  HStack {
                    Text(viewStore.geocoded?.address.street?.string ?? "Search address")
                      .frame(
                        width: geometry.size.width - 126,
                        height: 20,
                        alignment: .leading
                      )
                      .font(
                        Font.system(size: 14)
                          .weight(.medium))
                      .clipped()
                      .offset(x: 16)
                      .padding(.trailing, 16)
                      .animation(nil)
                    Image(systemName: "magnifyingglass")
                      .foregroundColor(Color(.secondaryLabel))
                      .padding(.trailing, 12)
                  }
                  Button(action: {
                    
                  }) {
                    Rectangle()
                      .fill(Color(.secondarySystemFill))
                      .opacity(0.1)
                  }
                  .background(Color.clear)
                }
                .frame(width: geometry.size.width - 60, height: 44)
                .background(Color(.systemFill))
                .cornerRadius(22)
              }
              .padding([.leading, .trailing, .top, .bottom], 16)
            }
            .background(Color(.systemBackground))
            .clipped()
            .shadow(radius: 5)
            PlaceMapView(
              inputCoordinateForSearch: .init(
                get: {
                  viewStore.geocoded?.coordinate.coordinate2D
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
              },
              sendLiftedPin: {
                viewStore.send(.liftedAddPlaceCoordinatePin)
              }
            )
          }
          VStack {
            Spacer()
            PrimaryButton(
              variant: viewStore.geocoded?.coordinate != nil ? .normal(title: "Confirm") : .disabled(title: "Confirm"),
              isHovering: true
            ) {
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
