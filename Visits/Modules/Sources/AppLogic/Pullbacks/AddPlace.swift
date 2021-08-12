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

private let addPlaceStateAffine = /AppState.operational ** \.flow ** /AppFlow.main ** addPlaceMainStateAffine

private let addPlaceMainStateAffine = Affine<MainState, AddPlaceState>(
  extract: { s in
    s.history <¡> { h in
      .init(adding: s.addPlace, history: h)
    }
  },
  inject: { d in
     \.addPlace *< d.adding <> \.history *< d.history
  }
)

private let addPlaceActionPrism = Prism<AppAction, AddPlaceAction>(
  extract: { a in
    switch a {
    case     .addPlace:                                   return .addPlace
    case let .addPlaceDescriptionUpdated(d):              return .addPlaceDescriptionUpdated(d)
    case     .cancelAddPlace:                             return .cancelAddPlace
    case     .cancelChoosingAddress:                      return .cancelChoosingAddress
    case     .cancelChoosingCompany:                      return .cancelChoosingCompany
    case     .cancelConfirmingLocation:                   return .cancelConfirmingLocation
    case     .cancelEditingAddPlaceMetadata:              return .cancelEditingAddPlaceMetadata
    case     .chooseCompany:                              return .chooseCompany
    case     .confirmAddPlaceCoordinate:                  return .confirmAddPlaceCoordinate
    case let .confirmAddPlaceLocation(mp):                return .confirmAddPlaceLocation(mp)
    case let .createPlace(c, r, ie, a, d):                return .createPlace(c, r, ie, a, d)
    case     .createPlaceTapped:                          return .createPlaceTapped
    case let .customAddressUpdated(a):                    return .customAddressUpdated(a)
    case     .decreaseAddPlaceRadius:                     return .decreaseAddPlaceRadius
    case     .increaseAddPlaceRadius:                     return .increaseAddPlaceRadius
    case let .integrationEntitiesUpdatedWithFailure(e):   return .integrationEntitiesUpdatedWithFailure(e)
    case let .integrationEntitiesUpdatedWithSuccess(ies): return .integrationEntitiesUpdatedWithSuccess(ies)
    case     .liftedAddPlaceCoordinatePin:                return .liftedAddPlaceCoordinatePin
    case let .localSearchCompletionResultsUpdated(lss):   return .localSearchCompletionResultsUpdated(lss)
    case let .localSearchUpdatedWithResult(mp):           return .localSearchUpdatedWithResult(mp)
    case let .localSearchUpdatedWithResults(mp, mps):     return .localSearchUpdatedWithResults(mp, mps)
    case     .localSearchUpdatedWithEmptyResult:          return .localSearchUpdatedWithEmptyResult
    case let .localSearchUpdatedWithError(e):             return .localSearchUpdatedWithError(e)
    case     .localSearchUpdatedWithFatalError:           return .localSearchUpdatedWithFatalError
    case let .placeCreatedWithSuccess(p):                 return .placeCreatedWithSuccess(p)
    case let .placeCreatedWithFailure(e):                 return .placeCreatedWithFailure(e)
    case let .reverseGeocoded(gr):                        return .reverseGeocoded(gr)
    case     .searchForIntegrations:                      return .searchForIntegrations
    case     .searchPlaceByAddress:                       return .searchPlaceByAddress
    case     .searchPlaceOnMap:                           return .searchPlaceOnMap
    case let .selectAddress(ls):                          return .selectAddress(ls)
    case let .selectPlace(.some(p)):                      return .selectPlace(p)
    case let .selectedIntegration(ie):                    return .selectedIntegration(ie)
    case let .updateAddressSearch(st):                    return .updateAddressSearch(st)
    case let .updateIntegrations(s):                      return .updateIntegrations(s)
    case let .updateIntegrationsSearch(s):                return .updateIntegrationsSearch(s)
    case let .updatedAddPlaceCoordinate(c):               return .updatedAddPlaceCoordinate(c)
    default:                                              return nil
    }
  },
  embed: { a in
    switch a {
    case     .addPlace:                                   return .addPlace
    case let .addPlaceDescriptionUpdated(d):              return .addPlaceDescriptionUpdated(d)
    case     .cancelAddPlace:                             return .cancelAddPlace
    case     .cancelChoosingAddress:                      return .cancelChoosingAddress
    case     .cancelChoosingCompany:                      return .cancelChoosingCompany
    case     .cancelConfirmingLocation:                   return .cancelConfirmingLocation
    case     .cancelEditingAddPlaceMetadata:              return .cancelEditingAddPlaceMetadata
    case     .chooseCompany:                              return .chooseCompany
    case     .confirmAddPlaceCoordinate:                  return .confirmAddPlaceCoordinate
    case let .confirmAddPlaceLocation(mp):                return .confirmAddPlaceLocation(mp)
    case let .createPlace(c, r, ie, a, d):                return .createPlace(c, r, ie, a, d)
    case     .createPlaceTapped:                          return .createPlaceTapped
    case let .customAddressUpdated(a):                    return .customAddressUpdated(a)
    case     .decreaseAddPlaceRadius:                     return .decreaseAddPlaceRadius
    case     .increaseAddPlaceRadius:                     return .increaseAddPlaceRadius
    case let .integrationEntitiesUpdatedWithFailure(e):   return .integrationEntitiesUpdatedWithFailure(e)
    case let .integrationEntitiesUpdatedWithSuccess(ies): return .integrationEntitiesUpdatedWithSuccess(ies)
    case     .liftedAddPlaceCoordinatePin:                return .liftedAddPlaceCoordinatePin
    case let .localSearchCompletionResultsUpdated(lss):   return .localSearchCompletionResultsUpdated(lss)
    case let .localSearchUpdatedWithResult(mp):           return .localSearchUpdatedWithResult(mp)
    case let .localSearchUpdatedWithResults(mp, mps):     return .localSearchUpdatedWithResults(mp, mps)
    case     .localSearchUpdatedWithEmptyResult:          return .localSearchUpdatedWithEmptyResult
    case let .localSearchUpdatedWithError(e):             return .localSearchUpdatedWithError(e)
    case     .localSearchUpdatedWithFatalError:           return .localSearchUpdatedWithFatalError
    case let .placeCreatedWithSuccess(p):                 return .placeCreatedWithSuccess(p)
    case let .placeCreatedWithFailure(e):                 return .placeCreatedWithFailure(e)
    case let .reverseGeocoded(gr):                        return .reverseGeocoded(gr)
    case     .searchForIntegrations:                      return .searchForIntegrations
    case     .searchPlaceByAddress:                       return .searchPlaceByAddress
    case     .searchPlaceOnMap:                           return .searchPlaceOnMap
    case let .selectAddress(ls):                          return .selectAddress(ls)
    case let .selectPlace(p):                             return .selectPlace(p)
    case let .selectedIntegration(ie):                    return .selectedIntegration(ie)
    case let .updateAddressSearch(st):                    return .updateAddressSearch(st)
    case let .updateIntegrations(s):                      return .updateIntegrations(s)
    case let .updateIntegrationsSearch(s):                return .updateIntegrationsSearch(s)
    case let .updatedAddPlaceCoordinate(c):               return .updatedAddPlaceCoordinate(c)
    }
  }
)
