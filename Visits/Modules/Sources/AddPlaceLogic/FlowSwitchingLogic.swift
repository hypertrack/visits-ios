import AppArchitecture
import ComposableArchitecture
import Types
import Utility


// MARK: - Action

enum FlowSwitchingAction: Equatable {
  case addPlace
  case cancelAddPlace
  case cancelChoosingAddress
  case cancelEditingAddPlaceMetadata
  case confirmAddPlaceCoordinate
  case confirmAddPlaceLocation(MapPlace)
  case integrationEntitiesUpdatedWithSuccess([IntegrationEntity])
  case localSearchCompletionResultsUpdated([LocalSearchCompletion])
  case localSearchUpdatedWithResult(MapPlace)
  case placeCreatedWithSuccess(Place)
  case reverseGeocoded(GeocodedResult)
  case searchPlaceByAddress
  case searchPlaceOnMap
  case selectPlace(Place)
  case updateIntegrations(IntegrationSearch)
}

let flowSwitchingActionPrism = Prism<AddPlaceAction, FlowSwitchingAction>(
  extract: { a in
    switch a {
    case     .addPlace:                                   return .addPlace
    case     .cancelAddPlace:                             return .cancelAddPlace
    case     .cancelChoosingAddress:                      return .cancelChoosingAddress
    case     .cancelEditingAddPlaceMetadata:              return .cancelEditingAddPlaceMetadata
    case     .confirmAddPlaceCoordinate:                  return .confirmAddPlaceCoordinate
    case let .confirmAddPlaceLocation(mp):                return .confirmAddPlaceLocation(mp)
    case let .integrationEntitiesUpdatedWithSuccess(ies): return .integrationEntitiesUpdatedWithSuccess(ies)
    case let .localSearchCompletionResultsUpdated(lss):   return .localSearchCompletionResultsUpdated(lss)
    case let .localSearchUpdatedWithResult(mp):           return .localSearchUpdatedWithResult(mp)
    case let .placeCreatedWithSuccess(p):                 return .placeCreatedWithSuccess(p)
    case let .reverseGeocoded(gr):                        return .reverseGeocoded(gr)
    case     .searchPlaceByAddress:                       return .searchPlaceByAddress
    case     .searchPlaceOnMap:                           return .searchPlaceOnMap
    case let .selectPlace(p):                             return .selectPlace(p)
    case let .updateIntegrations(s):                      return .updateIntegrations(s)
    default: return nil
    }
  },
  embed: { a in
    switch a {
    case     .addPlace:                                   return .addPlace
    case     .cancelAddPlace:                             return .cancelAddPlace
    case     .cancelChoosingAddress:                      return .cancelChoosingAddress
    case     .cancelEditingAddPlaceMetadata:              return .cancelEditingAddPlaceMetadata
    case     .confirmAddPlaceCoordinate:                  return .confirmAddPlaceCoordinate
    case let .confirmAddPlaceLocation(mp):                return .confirmAddPlaceLocation(mp)
    case let .integrationEntitiesUpdatedWithSuccess(ies): return .integrationEntitiesUpdatedWithSuccess(ies)
    case let .localSearchCompletionResultsUpdated(lss):   return .localSearchCompletionResultsUpdated(lss)
    case let .localSearchUpdatedWithResult(mp):           return .localSearchUpdatedWithResult(mp)
    case let .placeCreatedWithSuccess(p):                 return .placeCreatedWithSuccess(p)
    case let .reverseGeocoded(gr):                        return .reverseGeocoded(gr)
    case     .searchPlaceByAddress:                       return .searchPlaceByAddress
    case     .searchPlaceOnMap:                           return .searchPlaceOnMap
    case let .selectPlace(p):                             return .selectPlace(p)
    case let .updateIntegrations(s):                      return .updateIntegrations(s)
    }
  }
)

// MARK: - Environment

struct FlowSwitchingEnvironment {
  var capture: (CaptureMessage) -> Effect<Never, Never>
  var reverseGeocode: (Coordinate) -> Effect<GeocodedResult, Never>
  var subscribeToLocalSearchCompletionResults: () -> Effect<[LocalSearchCompletion], Never>
}

func toFlowSwitchingEnvironment(_ e: SystemEnvironment<AddPlaceEnvironment>) -> SystemEnvironment<FlowSwitchingEnvironment> {
  e.map { e in
    .init(
      capture: e.capture,
      reverseGeocode: e.reverseGeocode,
      subscribeToLocalSearchCompletionResults: e.subscribeToLocalSearchCompletionResults
    )
  }
}

// MARK: - Reducer

let flowSwitchingP: Reducer<
  AddPlaceState,
  AddPlaceAction,
  SystemEnvironment<AddPlaceEnvironment>
> = flowSwitchingReducer.pullback(
  state: Lens<AddPlaceState, AddPlaceState>.`self`.toAffine(),
  action: flowSwitchingActionPrism,
  environment: toFlowSwitchingEnvironment
)

let flowSwitchingReducer = Reducer<AddPlaceState, FlowSwitchingAction, SystemEnvironment<FlowSwitchingEnvironment>> { state, action, environment in

  let reverseGeocode = reverseGeocode(
    rge: environment.reverseGeocode,
    toA: FlowSwitchingAction.reverseGeocoded,
    main: environment.mainQueue
  )

   switch action {
   case .addPlace:
     guard state.adding == nil
     else { return environment.capture("Can't add place when already adding place").fireAndForget() }

     guard let currentLocation = state.history.coordinates.last else { return .none }

     state.adding = .init(
       flow: .choosingCoordinate(.init(coordinate: currentLocation)),
       entities: []
     )

     return .merge(
       reverseGeocode(currentLocation),
       Effect(value: .updateIntegrations(""))
     )
   case .cancelAddPlace:
     guard case .choosingCoordinate = state.adding?.flow
     else { return environment.capture("Trying to cancel adding place when not choosing coordinate").fireAndForget() }

     state.adding = nil

     return .none
   case .cancelChoosingAddress:
     guard case .choosingAddress = state.adding?.flow
     else { return environment.capture("Trying to cancel choosing address when not choosing address").fireAndForget() }

     state.adding = nil

     return .none
   case .cancelEditingAddPlaceMetadata:
    guard let adding = state.adding,
          case let .editingMetadata(em) = adding.flow
     else { return environment.capture("Trying to cancel editing add place metadata when not editing screen").fireAndForget() }

    state.adding = adding |> \.flow *< .choosingCoordinate(.init(coordinate: em.center.rawValue))

    return .none
   case .confirmAddPlaceCoordinate:
    guard let adding = state.adding,
          let gr = adding *^? \.flow ** /AddPlaceFlow.choosingCoordinate ** Optional.prism
     else { return environment.capture("Trying to confirm a place coordinate when not on choosing coordinate screen or in flight").fireAndForget() }

    state.adding = adding |> \.flow *< .editingMetadata(.init(center: .init(rawValue: gr.coordinate)))

     return .none
   case let .confirmAddPlaceLocation(mp):
    guard let adding = state.adding,
          let _ = adding *^? \.flow ** /AddPlaceFlow.choosingAddress ** \.flow ** /ChoosingAddressFlow.confirming
     else { return environment.capture("Trying to confirm a place location when not in place location confirmation screen").fireAndForget() }

    state.adding = adding |> \.flow *< .editingMetadata(.init(center: .init(rawValue: mp.location)))

     return .none
   case let .integrationEntitiesUpdatedWithSuccess(ies):
     guard let adding = state.adding else { return .none }

     state.adding = adding |> \.entities *< ies

     return .none
   case .localSearchCompletionResultsUpdated:
    return .none
   case let .localSearchUpdatedWithResult(mp):
    guard let adding = state.adding,
          let ca = adding *^? \.flow ** /AddPlaceFlow.choosingAddress,
          let sfa = ca *^? \.flow ** /ChoosingAddressFlow.searching,
          let s = sfa.search,
          let sel = sfa.selected
    else { return .none }

    state.adding = adding |> \.flow *< .editingMetadata(.init(center: .init(rawValue: mp.location)))

     return .none
   case .placeCreatedWithSuccess:
    guard let _ = state *^? \.adding ** Optional.prism ** \.flow ** /AddPlaceFlow.editingMetadata ** \.flow ** /AddPlaceMetadataFlow.adding
     else { return environment.capture("Place creation returned when user wasn't on the waiting screen").fireAndForget() }

    state.adding = nil

     return .none
   case .reverseGeocoded:
    return .none
   case .searchPlaceByAddress:
    guard let adding = state.adding,
          let _ = adding *^? \.flow ** /AddPlaceFlow.choosingCoordinate
    else { return environment.capture("Trying to switch to searching by address when not in search by coordinate view").fireAndForget() }
    guard let currentLocation = state.history.coordinates.last else { return .none }

    state.adding = adding |> \.flow *< .choosingAddress(.init(currentLocation: .init(rawValue: currentLocation)))

     return .none
   case .searchPlaceOnMap:
    guard let adding = state.adding,
          let _ = adding *^? \.flow ** /AddPlaceFlow.choosingAddress
    else { return environment.capture("Trying to switch to map when searching places when not in search by address view").fireAndForget() }
    guard let currentLocation = state.history.coordinates.last else { return .none }

    state.adding = adding |> \.flow *< .choosingCoordinate(.init(coordinate: currentLocation))

    return .none
   case let .selectPlace(p):
    guard let _ = state *^? \.adding ** Optional.prism ** \.flow ** /AddPlaceFlow.choosingCoordinate
    else { return .none }

     state.adding = nil

     return .none
   case .updateIntegrations:
     return .none
  }
}
.onEntry(
  chooseAddressState,
  send: { _, e in
    subscribeToLocalSearchCompletionResults(
      s: e.subscribeToLocalSearchCompletionResults,
      main: e.mainQueue
    )
  }
)
.onExit(
  chooseAddressState,
  send: constant(.cancel(id: LocalSearchCompletionResultsSubscriptionID()))
)
.onEntry(
  chooseIntegrationState,
  send: constant(Effect(value: .updateIntegrations("")))
)
.onExit(
  chooseIntegrationState,
  send: constant(Effect(value: .updateIntegrations("")))
)

func chooseIntegrationState(_ state: AddPlaceState) -> Terminal? {
  state *^? \.adding ** Optional.prism ** \.flow ** /AddPlaceFlow.editingMetadata ** \.flow ** /AddPlaceMetadataFlow.choosingIntegration
  <¡> constant(unit)
}

func chooseAddressState(_ state: AddPlaceState) -> Terminal? {
  state *^? \.adding ** Optional.prism ** \.flow ** /AddPlaceFlow.choosingAddress
    <¡> constant(unit)
}
