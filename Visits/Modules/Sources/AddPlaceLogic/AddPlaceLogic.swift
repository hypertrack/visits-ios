import ComposableArchitecture
import Types
import Utility


// MARK: - State

public struct AddPlaceState: Equatable {
  public var flow: AddPlaceFlow?
  public var history: History?
  
  public init(flow: AddPlaceFlow? = nil, history: History?) { self.flow = flow; self.history = history }
}

// MARK: - Action

public enum AddPlaceAction: Equatable {
  case addPlace
  case cancelAddPlace
  case confirmAddPlaceCoordinate
  case updatedAddPlaceCoordinate(Coordinate)
  case cancelChoosingCompany
  case updateIntegrationsSearch(Search)
  case searchForIntegrations
  case selectedIntegration(IntegrationEntity)
  case updateIntegrations(Search)
  case integrationEntitiesUpdated(Result<[IntegrationEntity], APIError<Token.Expired>>)
  case createPlace(Coordinate, IntegrationEntity)
}

// MARK: - Environment

public struct AddPlaceEnvironment {
  public var capture: (CaptureMessage) -> Effect<Never, Never>
  
  public init(
    capture: @escaping (CaptureMessage) -> Effect<Never, Never>
  ) {
    self.capture = capture
  }
}

// MARK: - Reducer

public let addPlaceReducer = Reducer<AddPlaceState, AddPlaceAction, AddPlaceEnvironment> { state, action, environment in
  switch action {
  case .addPlace:
    guard state.flow == nil
    else { return environment.capture("Can't add place when already adding place").fireAndForget() }
    
    state.flow = .choosingCoordinate(state.history?.coordinates.last, [])
    
    return Effect(value: .updateIntegrations(""))
  case .cancelAddPlace:
    guard state.flow != nil
    else { return environment.capture("Trying to cancel adding place when already canceled").fireAndForget() }
    
    state.flow = nil
    
    return .none
  case .confirmAddPlaceCoordinate:
    guard case let .choosingCoordinate(c, ies) = state.flow, let c = c
    else { return environment.capture("Trying to confirm a place coordinate without coordinate").fireAndForget() }
    
    state.flow = .choosingIntegration(c, "", .notRefreshing, ies)
    
    return .none
  case let .updatedAddPlaceCoordinate(c):
    guard case let .choosingCoordinate(_, ies) = state.flow
    else { return environment.capture("Trying to update the place coordinate when not adding place").fireAndForget() }
    
    state.flow = .choosingCoordinate(c, ies)
    
    return .none
  case .cancelChoosingCompany:
    guard case let .choosingIntegration(c, _, _, ies) = state.flow
    else { return environment.capture("Trying to cancel choosing company when not choosing company").fireAndForget() }
    
    state.flow = .choosingCoordinate(c, ies)
    
    return .none
  case let .updateIntegrationsSearch(s):
    guard case let .choosingIntegration(c, _, r, ies) = state.flow
    else { return environment.capture("Trying to update integration search when not searching for integrations").fireAndForget() }
    
    state.flow = .choosingIntegration(c, s, r, ies)
    
    return .none
  case .searchForIntegrations:
    guard case let .choosingIntegration(c, s, r, ies) = state.flow
    else { return environment.capture("Trying to search for integrations when not searching for integrations").fireAndForget() }
    
    state.flow = .choosingIntegration(c, s, .refreshing, ies)
    
    return Effect(value: .updateIntegrations(s))
  case let .selectedIntegration(ie):
    guard case let .choosingIntegration(c, s, _, ies) = state.flow
    else { return environment.capture("Trying to select the integration when not searching for integrations").fireAndForget() }
    
    state.flow = .addingPlace(c, ie, s, ies)
    
    return Effect(value: .createPlace(c, ie))
  case let .integrationEntitiesUpdated(.success(ies)):
    switch state.flow {
    case .none:                                break
    case let .choosingCoordinate(c, _):        state.flow = .choosingCoordinate(c, ies)
    case let .choosingIntegration(c, s, _, _): state.flow = .choosingIntegration(c, s, .notRefreshing, ies)
    case let .addingPlace(c, ie, s, _):        state.flow = .addingPlace(c, ie, s, ies)
    }
    
    return .none
  case .integrationEntitiesUpdated(.failure):
    if case let .choosingIntegration(c, s, _, ies) = state.flow {
      state.flow = .choosingIntegration(c, s, .notRefreshing, ies)
    }
    
    return .none
  case .updateIntegrations:
    return .none
  case .createPlace:
    return .none
  }
}
