import ComposableArchitecture
import MapDetailView
import MapKit
import SwiftUI
import Types
import Utility
import Views
import DestinationPickerScreen

public struct AddPlaceView: View {
  public struct State: Equatable {
    public var adding: AddPlace
    public var places: Set<Place>
    
    public init(adding: AddPlace, places: Set<Place>) { self.adding = adding; self.places = places }
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
    case updateAddressSearch(AddressSearch?)
    // Confirming Location
    case cancelConfirmingLocation
    case confirmAddPlaceLocation(MapPlace)
    // Choosing Integration
    case cancelChoosingCompany
    case searchForIntegrations
    case selectedIntegration(IntegrationEntity)
    case updateIntegrationsSearch(IntegrationSearch)
    // Editing Metadata
    case addPlaceDescriptionUpdated(PlaceDescription?)
    case cancelEditingAddPlaceMetadata
    case chooseCompany
    case createPlaceTapped
    case customAddressUpdated(CustomAddress?)
    case decreaseAddPlaceRadius
    case increaseAddPlaceRadius
    
    case selectedPlace(Place)
    
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
      case let .choosingAddress(ca):
        switch ca.flow {
        case let .searching(sfa):
          ChoosingAddressView(
            store: store.scope(
              state: constant(
                .init(
                  search: sfa.search,
                  searchResults: ca.results,
                  selectedResult: sfa.selected
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
        case let .confirming(cal):
          ConfirmingLocationView(
            store: store.scope(
              state: constant(
                .init(
                  selectedResult: cal.selected,
                  locations: cal.locations
                )
              ),
              action: { a in
                switch a {
                case     .cancelConfirmingLocation:    return .cancelConfirmingLocation
                case let .confirmAddPlaceLocation(mp): return .confirmAddPlaceLocation(mp)
                }
              }
            )
          )
        }
      case let .editingMetadata(em):
        switch em.flow {
        case let .editing(ie):
          EditingMetadataView(
            store: store.scope(
              state: constant(
                .init(
                  center: em.center,
                  radius: em.radius,
                  address: em.customAddress,
                  description: em.description,
                  company: ie
                )
              ),
              action: { a in
                switch a {
                case let .addPlaceDescriptionUpdated(d): return .addPlaceDescriptionUpdated(d)
                case     .cancelEditingAddPlaceMetadata: return .cancelEditingAddPlaceMetadata
                case     .chooseCompany:                 return .chooseCompany
                case     .createPlaceTapped:             return .createPlaceTapped
                case let .customAddressUpdated(a):       return .customAddressUpdated(a)
                case     .decreaseAddPlaceRadius:        return .decreaseAddPlaceRadius
                case     .increaseAddPlaceRadius:        return .increaseAddPlaceRadius
                }
              }
            )
          )
        case let .choosingIntegration(ci):
          ChoosingCompanyView(
            store: store.scope(
              state: constant(
                .init(
                  search: ci.search,
                  integrationEntities: viewStore.adding.entities,
                  refreshing: ci.status == .refreshing
                )
              ),
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
        case let .adding(ie):
          VStack(spacing: 0) {
            MapDetailView(
              object: .place(
                Place(
                  id: "Temp",
                  address: .none,
                  createdAt: .init(rawValue: Date()),
                  shape: .circle(
                    .init(
                      center: em.center.rawValue,
                      radius: UInt(em.radius.rawValue)
                    )
                  ),
                  visits: []
                )
              )
            )
            .frame(height: 250)
            if let a = em.customAddress {
              ContentCell(
                title: "Address",
                subTitle: a.string,
                leadingPadding: 24,
                isCopyButtonEnabled: true,
                { str in }
              )
              .padding(.top, 8)
            }
            if let d = em.description {
              ContentCell(
                title: "Description",
                subTitle: d.string,
                leadingPadding: 24,
                isCopyButtonEnabled: true,
                { str in }
              )
              .padding(.top, 8)
            }
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
}
