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
      autocompleteLocalSearch: e.maps.autocompleteLocalSearch,
      capture: e.errorReporting.capture,
      localSearch: e.maps.localSearch,
      reverseGeocode: e.maps.reverseGeocode,
      subscribeToLocalSearchCompletionResults: e.maps.subscribeToLocalSearchCompletionResults
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
    case     .addPlace:                                 return .addPlace
    case     .cancelAddPlace:                           return .cancelAddPlace
    case     .cancelChoosingCompany:                    return .cancelChoosingCompany
    case     .confirmAddPlaceCoordinate:                return .confirmAddPlaceCoordinate
    case let .createPlace(c, ie):                       return .createPlace(c, ie)
    case     .liftedAddPlaceCoordinatePin:              return .liftedAddPlaceCoordinatePin
    case let .placeCreated(r):                          return .placeCreated(r)
    case let .reverseGeocoded(gr):                      return .reverseGeocoded(gr)
    case let .integrationEntitiesUpdated(r):            return .integrationEntitiesUpdated(r)
    case     .searchForIntegrations:                    return .searchForIntegrations
    case let .selectedIntegration(ie):                  return .selectedIntegration(ie)
    case let .selectPlace(.some(p)):                    return .selectPlace(p)
    case let .updateIntegrations(s):                    return .updateIntegrations(s)
    case let .updateIntegrationsSearch(s):              return .updateIntegrationsSearch(s)
    case let .updatedAddPlaceCoordinate(c):             return .updatedAddPlaceCoordinate(c)
    case     .cancelChoosingAddress:                    return .cancelChoosingAddress
    case     .cancelConfirmingLocation:                 return .cancelConfirmingLocation
    case let .confirmAddPlaceLocation(mp):              return .confirmAddPlaceLocation(mp)
    case let .localSearchCompletionResultsUpdated(lss): return .localSearchCompletionResultsUpdated(lss)
    case let .localSearchUpdated(r):                    return .localSearchUpdated(r)
    case     .searchPlaceByAddress:                     return .searchPlaceByAddress
    case     .searchPlaceOnMap:                         return .searchPlaceOnMap
    case let .selectAddress(ls):                        return .selectAddress(ls)
    case let .updateAddressSearch(st):                  return .updateAddressSearch(st)
    default:                                            return nil
    }
  },
  embed: { a in
    switch a {
    case     .addPlace:                                 return .addPlace
    case     .cancelAddPlace:                           return .cancelAddPlace
    case     .cancelChoosingCompany:                    return .cancelChoosingCompany
    case     .confirmAddPlaceCoordinate:                return .confirmAddPlaceCoordinate
    case let .createPlace(c, ie):                       return .createPlace(c, ie)
    case     .liftedAddPlaceCoordinatePin:              return .liftedAddPlaceCoordinatePin
    case let .placeCreated(r):                          return .placeCreated(r)
    case let .reverseGeocoded(gr):                      return .reverseGeocoded(gr)
    case let .integrationEntitiesUpdated(r):            return .integrationEntitiesUpdated(r)
    case     .searchForIntegrations:                    return .searchForIntegrations
    case let .selectedIntegration(ie):                  return .selectedIntegration(ie)
    case let .selectPlace(p):                           return .selectPlace(p)
    case let .updateIntegrations(s):                    return .updateIntegrations(s)
    case let .updateIntegrationsSearch(s):              return .updateIntegrationsSearch(s)
    case let .updatedAddPlaceCoordinate(c):             return .updatedAddPlaceCoordinate(c)
    case     .cancelChoosingAddress:                    return .cancelChoosingAddress
    case     .cancelConfirmingLocation:                 return .cancelConfirmingLocation
    case let .confirmAddPlaceLocation(mp):              return .confirmAddPlaceLocation(mp)
    case let .localSearchCompletionResultsUpdated(lss): return .localSearchCompletionResultsUpdated(lss)
    case let .localSearchUpdated(r):                    return .localSearchUpdated(r)
    case     .searchPlaceByAddress:                     return .searchPlaceByAddress
    case     .searchPlaceOnMap:                         return .searchPlaceOnMap
    case let .selectAddress(ls):                        return .selectAddress(ls)
    case let .updateAddressSearch(st):                  return .updateAddressSearch(st)
    }
  }
)
