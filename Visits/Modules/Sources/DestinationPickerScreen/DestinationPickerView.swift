import ComposableArchitecture
import MapDetailView
import MapKit
import SwiftUI
import Types
import Utility
import Views

public struct DestinationPickerView: View {
  public struct State: Equatable {
    enum Flow {
      case choosingCoordinate(GeocodedResult?)
      case choosingAddress(ChoosingAddress)
    }
  }
  
  public enum Action: Equatable {
    // Choosing Coordinate
    case cancel
    case confirmCoordinate
    case liftedCoordinatePin
    case searchByAddress
    case updatedCoordinate(Coordinate)
    // Choosing Address
    case cancelChoosingAddress
    case searchOnMap
    case selectAddress(LocalSearchCompletion)
    case updateAddressSearch(AddressSearch?)
  }
  
  let store: Store<State, Action>
  public init(store: Store<State, Action>) { self.store = store }
  
  public var body: some View {
    WithViewStore(store) { viewStore in
      switch viewStore.adding.flow {
      case let .choosingCoordinate(gr):
        ChoosingCoordinateView(
          store: store.scope(
            state: constant(.init(geocoded: gr, places: viewStore.places)),
            action: { a in
              switch a {
              case     .cancel:               return .cancel
              case     .liftedCoordinatePin:  return .liftedCoordinatePin
              case let .updateCoordinate(c):  return .updatedCoordinate(c)
              case     .confirmCoordinate:    return .confirmCoordinate
              case     .searchPlaceByAddress: return .searchPlaceByAddress
              }
            }
          )
        )
      case let .choosingAddress(ca):
        ChoosingAddressView(
          store: store.scope(
            state: constant(
              .init(
                search: ca.search,
                searchResults: ca.results,
                selectedResult: ca.selected
              )
            ),
            action: { a in
              switch a {
              case     .cancelChoosingAddress:   return .cancelChoosingAddress
              case     .searchPlaceOnMap:        return .searchPlaceOnMap
              case let .selectAddress(ls):       return .selectAddress(ls)
              case let .updateAddressSearch(st): return .updateAddressSearch(st)
              }
            }
          )
        )
      }
    }
  }
}
