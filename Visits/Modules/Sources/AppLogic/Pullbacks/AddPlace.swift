import AddPlaceLogic
import AppArchitecture
import ComposableArchitecture
import Utility
import Types


let addPlaceP: Reducer<
  AppState,
  AppAction,
  SystemEnvironment<AppEnvironment>
> = addPlaceReducer.pullback(
  state: addPlaceStateAffine,
  action: addPlaceActionPrism,
  environment: toAddPlaceEnvironment
)

private func toAddPlaceEnvironment(_ e: SystemEnvironment<AppEnvironment>) -> SystemEnvironment<AddPlaceEnvironment> {
  e.map { e in
    .init(
      capture: e.errorReporting.capture,
      reverseGeocode: e.maps.reverseGeocode
    )
  }
}

private let addPlaceStateAffine = /AppState.operational ** \.flow ** /AppFlow.main ** addPlaceMainStateLens

private let addPlaceMainStateLens = Lens<MainState, AddPlaceState>(
  get: { s in
    .init(flow: s.addPlace, history: s.history)
  },
  set: { d in
     \.addPlace *< d.flow <> \.history *< d.history
  }
)

private let addPlaceActionPrism = Prism<AppAction, AddPlaceAction>(
  extract: { a in
    switch a {
    case     .addPlace:                      return .addPlace
    case     .cancelAddPlace:                return .cancelAddPlace
    case     .cancelChoosingCompany:         return .cancelChoosingCompany
    case     .confirmAddPlaceCoordinate:     return .confirmAddPlaceCoordinate
    case let .createPlace(c, ie):            return .createPlace(c, ie)
    case     .liftedAddPlaceCoordinatePin:   return .liftedAddPlaceCoordinatePin
    case let .placeCreated(r):               return .placeCreated(r)
    case let .reverseGeocoded(gr):           return .reverseGeocoded(gr)
    case let .integrationEntitiesUpdated(r): return .integrationEntitiesUpdated(r)
    case     .searchForIntegrations:         return .searchForIntegrations
    case let .selectedIntegration(ie):       return .selectedIntegration(ie)
    case let .selectPlace(.some(p)):         return .selectPlace(p)
    case let .updateIntegrations(s):         return .updateIntegrations(s)
    case let .updateIntegrationsSearch(s):   return .updateIntegrationsSearch(s)
    case let .updatedAddPlaceCoordinate(c):  return .updatedAddPlaceCoordinate(c)
    default:                                 return nil
    }
  },
  embed: { a in
    switch a {
    case     .addPlace:                      return .addPlace
    case     .cancelAddPlace:                return .cancelAddPlace
    case     .cancelChoosingCompany:         return .cancelChoosingCompany
    case     .confirmAddPlaceCoordinate:     return .confirmAddPlaceCoordinate
    case let .createPlace(c, ie):            return .createPlace(c, ie)
    case     .liftedAddPlaceCoordinatePin:   return .liftedAddPlaceCoordinatePin
    case let .placeCreated(r):               return .placeCreated(r)
    case let .reverseGeocoded(gr):           return .reverseGeocoded(gr)
    case let .integrationEntitiesUpdated(r): return .integrationEntitiesUpdated(r)
    case     .searchForIntegrations:         return .searchForIntegrations
    case let .selectedIntegration(ie):       return .selectedIntegration(ie)
    case let .selectPlace(p):                return .selectPlace(p)
    case let .updateIntegrations(s):         return .updateIntegrations(s)
    case let .updateIntegrationsSearch(s):   return .updateIntegrationsSearch(s)
    case let .updatedAddPlaceCoordinate(c):  return .updatedAddPlaceCoordinate(c)
    }
  }
)
