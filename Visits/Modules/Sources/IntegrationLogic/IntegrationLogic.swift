import ComposableArchitecture
import Types


// MARK: - Action

public enum IntegrationAction: Equatable {
  case integrationEntitiesUpdatedWithSuccess([IntegrationEntity])
  case integrationEntitiesUpdatedWithFailure(APIError<Token.Expired>)
}

// MARK: - Reducer

public let integrationReducer = Reducer<IntegrationStatus, IntegrationAction, Void> { state, action, _ in
  switch action {
  case let .integrationEntitiesUpdatedWithSuccess(ies):
    switch (state, ies.first) {
    case (.requesting, .some), (.unknown, .some): state = .integrated(.notRefreshing)
    case (.requesting, .none), (.unknown, .none): state = .notIntegrated
    default: break
    }
    
    return .none
  case .integrationEntitiesUpdatedWithFailure:
    guard state == .requesting else { return .none }
    
    state = .unknown
    
    return .none
  }
}

