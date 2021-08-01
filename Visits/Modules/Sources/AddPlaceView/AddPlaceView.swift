import ComposableArchitecture
import MapKit
import SwiftUI
import Types
import Utility
import Views


public struct AddPlaceView: View {
  public struct State: Equatable {
    public var flow: AddPlaceFlow
    
    public init(flow: AddPlaceFlow) { self.flow = flow }
  }
  
  public enum Action: Equatable {
    case cancelAddPlace
    case updatedAddPlaceCoordinate(Coordinate)
    case confirmAddPlaceCoordinate
  }
  
  let store: Store<State, Action>
  public init(store: Store<State, Action>) { self.store = store }
  
  public var body: some View {
    WithViewStore(store) { viewStore in
      switch viewStore.flow {
      case let .choosingCoordinate(c):
        ChoosingCoordinateView(
          store: store.scope(
            state: constant(.init(coordinate: c)),
            action: { a in
              switch a {
              case     .cancelAddPlace:               return .cancelAddPlace
              case let .updatedAddPlaceCoordinate(c): return .updatedAddPlaceCoordinate(c)
              case     .confirmAddPlaceCoordinate:    return .confirmAddPlaceCoordinate
              }
            }
          )
        )
      case let .choosingIntegration(c):
        EmptyView()
      }
    }
  }
}


private struct ChoosingCoordinateView: View {
  struct State: Equatable {
    var coordinate: Coordinate?
  }
  enum Action {
    case cancelAddPlace
    case updatedAddPlaceCoordinate(Coordinate)
    case confirmAddPlaceCoordinate
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
            )
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
