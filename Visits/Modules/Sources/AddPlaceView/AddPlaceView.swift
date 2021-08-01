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
  }
  
  let store: Store<State, Action>
  public init(store: Store<State, Action>) { self.store = store }
  
  public var body: some View {
    WithViewStore(store) { viewStore in
      ZStack {
        PlaceMapView(
          inputCoordinateForSearch: .init(
            get: {
              viewStore.flow.placeCoordinate?.coordinate2D
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
      }
      .edgesIgnoringSafeArea(.all)
    }
  }
}
