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
    case cancelAddPlace
    case cancelChoosingCompany
    case liftedAddPlaceCoordinatePin
    case updatedAddPlaceCoordinate(Coordinate)
    case confirmAddPlaceCoordinate
    case updateIntegrationsSearch(Search)
    case searchForIntegrations
    case selectedIntegration(IntegrationEntity)
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
      case let .addingPlace(c, _, ie, _, _):
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
      }
    }
  }
}
