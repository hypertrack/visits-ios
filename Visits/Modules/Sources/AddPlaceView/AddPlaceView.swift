import ComposableArchitecture
import MapDetailView
import MapKit
import SwiftUI
import Types
import Utility
import Views


public struct AddPlaceView: View {
  public struct State: Equatable {
    public var flow: AddPlaceFlow
    public var places: Set<Place>
    
    public init(flow: AddPlaceFlow, places: Set<Place>) { self.flow = flow; self.places = places }
  }
  
  public enum Action: Equatable {
    // Choosing Coordinate
    case cancelAddPlace
    case confirmAddPlaceCoordinate
    case liftedAddPlaceCoordinatePin
    case searchPlaceByAddress
    case updatedAddPlaceCoordinate(Coordinate)
    // Choosing Address
    case cancelChoosingAddress
    case searchPlaceOnMap
    case selectAddress(LocalSearchCompletion)
    case updateAddressSearch(Street?)
    // Confirming Location
    case cancelConfirmingLocation
    case confirmAddPlaceLocation(MapPlace)
    // Choosing Integration
    case cancelChoosingCompany
    case searchForIntegrations
    case selectedIntegration(IntegrationEntity)
    case updateIntegrationsSearch(IntegrationEntity.Search)
    
    
    case selectedPlace(Place)
    
  }
  
  let store: Store<State, Action>
  public init(store: Store<State, Action>) { self.store = store }
  
  public var body: some View {
    WithViewStore(store) { viewStore in
      switch viewStore.flow {
      case let .choosingCoordinate(gr, _):
        ChoosingCoordinateView(
          store: store.scope(
            state: constant(.init(geocoded: gr, places: viewStore.places)),
            action: { a in
              switch a {
              case     .cancelAddPlace:               return .cancelAddPlace
              case     .liftedAddPlaceCoordinatePin:  return .liftedAddPlaceCoordinatePin
              case let .updatedAddPlaceCoordinate(c): return .updatedAddPlaceCoordinate(c)
              case     .confirmAddPlaceCoordinate:    return .confirmAddPlaceCoordinate
              case let .selectedPlace(p):             return .selectedPlace(p)
              case     .searchPlaceByAddress:         return .searchPlaceByAddress
              }
            }
          )
        )
      case let .choosingIntegration(_, _, s, r, ies):
        ChoosingCompanyView(
          store: store.scope(
            state: { _ in
              .init(search: s, integrationEntities: ies, refreshing: r == .refreshing)
            },
            action: { a in
              switch a {
              case     .cancelChoosingCompany:       return .cancelChoosingCompany
              case let .updateIntegrationsSearch(s): return .updateIntegrationsSearch(s)
              case     .searchForIntegrations:       return .searchForIntegrations
              case let .selectedIntegration(ie):     return .selectedIntegration(ie)
              }
            }
          )
        )
      case let .addingPlace(c, _, ie, _):
        VStack(spacing: 0) {
          MapDetailView(
            object: .place(
              .init(
                id: "Temp",
                address: .none,
                createdAt: .init(rawValue: Date()),
                shape: .circle(.init(center: c, radius: 150)),
                visits: []
              )
            )
          )
            .frame(height: 250)
          ContentCell(
            title: "Name",
            subTitle: ie.name.string,
            leadingPadding: 24,
            isCopyButtonEnabled: true,
            { str in }
          )
          .padding(.top, 8)
          Spacer()
          ProgressView("Creating Place")
            .padding()
          Spacer()
        }
        .edgesIgnoringSafeArea(.top)
      case let .choosingAddress(_, st, ls, lss, _):
        ChoosingAddressView(
          store: store.scope(
            state: constant(.init(search: st, searchResults: lss, selectedResult: ls)),
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
      case let .confirmingLocation(_, _, ls, mps, _, _):
        ConfirmingLocationView(
          store: store.scope(
            state: constant(.init(selectedResult: ls, locations: mps)),
            action: { a in
              switch a {
              case     .cancelConfirmingLocation:    return .cancelConfirmingLocation
              case let .confirmAddPlaceLocation(mp): return .confirmAddPlaceLocation(mp)
              }
            }
          )
        )
      }
    }
  }
}
