import AppArchitecture
import ComposableArchitecture
import Types
import Utility


// MARK: - Action

enum EditingMetadataAction: Equatable {
  case addPlaceDescriptionUpdated(PlaceDescription?)
  case cancelChoosingCompany
  case chooseCompany
  case createPlaceTapped
  case createPlace(PlaceCenter, PlaceRadius, IntegrationEntity, CustomAddress?, PlaceDescription?)
  case customAddressUpdated(CustomAddress?)
  case decreaseAddPlaceRadius
  case increaseAddPlaceRadius
  case integrationEntitiesUpdatedWithSuccess([IntegrationEntity])
  case integrationEntitiesUpdatedWithFailure(APIError<Token.Expired>)
  case placeCreatedWithFailure(APIError<Token.Expired>)
  case searchForIntegrations
  case selectedIntegration(IntegrationEntity)
  case updateIntegrations(IntegrationSearch)
  case updateIntegrationsSearch(IntegrationSearch)
}

let editingMetadataActionPrism = Prism<AddPlaceAction, EditingMetadataAction>(
  extract: { a in
    switch a {
    case let .addPlaceDescriptionUpdated(d):              return .addPlaceDescriptionUpdated(d)
    case     .cancelChoosingCompany:                      return .cancelChoosingCompany
    case     .chooseCompany:                              return .chooseCompany
    case let .createPlace(c, r, ie, a, d):                return .createPlace(c, r, ie, a, d)
    case     .createPlaceTapped:                          return .createPlaceTapped
    case     .decreaseAddPlaceRadius:                     return .decreaseAddPlaceRadius
    case     .increaseAddPlaceRadius:                     return .increaseAddPlaceRadius
    case let .integrationEntitiesUpdatedWithSuccess(ies): return .integrationEntitiesUpdatedWithSuccess(ies)
    case let .integrationEntitiesUpdatedWithFailure(e):   return .integrationEntitiesUpdatedWithFailure(e)
    case let .placeCreatedWithFailure(e):                 return .placeCreatedWithFailure(e)
    case     .searchForIntegrations:                      return .searchForIntegrations
    case let .selectedIntegration(ie):                    return .selectedIntegration(ie)
    case let .updateIntegrations(s):                      return .updateIntegrations(s)
    case let .updateIntegrationsSearch(s):                return .updateIntegrationsSearch(s)
    case let .customAddressUpdated(a):                    return .customAddressUpdated(a)
    default:                                              return nil
    }
  },
  embed: { a in
    switch a {
    case let .addPlaceDescriptionUpdated(d):              return .addPlaceDescriptionUpdated(d)
    case     .cancelChoosingCompany:                      return .cancelChoosingCompany
    case     .chooseCompany:                              return .chooseCompany
    case let .createPlace(c, r, ie, a, d):                return .createPlace(c, r, ie, a, d)
    case     .createPlaceTapped:                          return .createPlaceTapped
    case     .decreaseAddPlaceRadius:                     return .decreaseAddPlaceRadius
    case     .increaseAddPlaceRadius:                     return .increaseAddPlaceRadius
    case let .integrationEntitiesUpdatedWithSuccess(ies): return .integrationEntitiesUpdatedWithSuccess(ies)
    case let .integrationEntitiesUpdatedWithFailure(e):   return .integrationEntitiesUpdatedWithFailure(e)
    case let .placeCreatedWithFailure(e):                 return .placeCreatedWithFailure(e)
    case     .searchForIntegrations:                      return .searchForIntegrations
    case let .selectedIntegration(ie):                    return .selectedIntegration(ie)
    case let .updateIntegrations(s):                      return .updateIntegrations(s)
    case let .updateIntegrationsSearch(s):                return .updateIntegrationsSearch(s)
    case let .customAddressUpdated(a):                    return .customAddressUpdated(a)
    }
  }
)

// MARK: - Reducer

let editingMetadataP: Reducer<
  AddPlaceState,
  AddPlaceAction,
  SystemEnvironment<AddPlaceEnvironment>
> = editingMetadataReducer.pullback(
  state: \.adding ** Optional.prism ** \.flow ** /AddPlaceFlow.editingMetadata,
  action: editingMetadataActionPrism,
  environment: identity
)

let editingMetadataReducer = Reducer<AddPlaceMetadata, EditingMetadataAction, SystemEnvironment<AddPlaceEnvironment>> { state, action, environment in
  switch action {
  case let .addPlaceDescriptionUpdated(d):
    guard case .editing = state.flow
    else { return environment.capture("Trying to update add place description when not on the metadata editing screen").fireAndForget() }

    state.description = d

    return .none
  case .cancelChoosingCompany:
    guard case .choosingIntegration = state.flow
    else { return environment.capture("Trying to cancel choosing company when not choosing company").fireAndForget() }

    state.flow = .editing(nil)

    return .none
  case .chooseCompany:
    guard case .editing = state.flow
    else { return environment.capture("Trying to choose company when not editing metadata").fireAndForget() }

    state.flow = .choosingIntegration(.init(search: "", status: .notRefreshing))

    return .none
  case .createPlace:
    return .none
  case .createPlaceTapped:
    guard case let .editing(.some(ie)) = state.flow
    else { return environment.capture("Trying to create place when not on the metadata editing screen or integration is not chosen").fireAndForget() }

    state.flow = .adding(ie)

    return Effect(value: .createPlace(state.center, state.radius, ie, state.customAddress, state.description))
  case let .customAddressUpdated(a):
    guard case .editing = state.flow
    else { return environment.capture("Trying to update custom address when not on metadata editing screen").fireAndForget() }

    state.customAddress = a

    return .none
  case .decreaseAddPlaceRadius:
    guard case .editing = state.flow
    else { return environment.capture("Trying to decrease radius when not on the metadata editing screen").fireAndForget() }

    state.radius = state.radius.previous()

    return .none
  case .increaseAddPlaceRadius:
    guard case .editing = state.flow
    else { return environment.capture("Trying to decrease radius when not on the metadata editing screen").fireAndForget() }

    state.radius = state.radius.next()

    return .none
  case .integrationEntitiesUpdatedWithSuccess,
       .integrationEntitiesUpdatedWithFailure:
    guard case let .choosingIntegration(ci) = state.flow else { return .none }

    state.flow = .choosingIntegration(ci |> \.status *< .notRefreshing)

    return .none
  case .placeCreatedWithFailure:
    guard case let .adding(ie) = state.flow
    else { return environment.capture("Place creation returned failure when user wasn't on the waiting screen").fireAndForget() }

    state.flow = .editing(ie)

    return .none
  case .searchForIntegrations:
    guard case let .choosingIntegration(ci) = state.flow
    else { return environment.capture("Trying to search for integrations when not choosing an integration").fireAndForget() }

    state.flow = .choosingIntegration(ci |> \.status *< .refreshing)

    return Effect(value: .updateIntegrations(ci.search))
  case let .selectedIntegration(ie):
    guard case .choosingIntegration = state.flow
    else { return environment.capture("Trying to select the integration when not searching for integrations").fireAndForget() }

    state.flow = .editing(ie)

    return .none
  case .updateIntegrations:
    return .none
  case let .updateIntegrationsSearch(s):
    guard case let .choosingIntegration(ci) = state.flow
    else { return environment.capture("Trying to update integration search when not searching for integrations").fireAndForget() }

    state.flow = .choosingIntegration(ci |> \.search *< s)

    return .none
  }
}
