import ComposableArchitecture
import Types


// MARK: - Action

public enum IntegrationAction: Equatable {
  case integrationEntitiesUpdated(Result<[IntegrationEntity], APIError<Token.Expired>>)
}

// MARK: - Reducer

public let integrationReducer = Reducer<IntegrationStatus, IntegrationAction, Void> { state, action, _ in
  switch action {
  case let .integrationEntitiesUpdated(.success(ies)):
    switch (state, ies.first) {
    case (.requesting, .some), (.unknown, .some): state = .integrated
    case (.requesting, .none), (.unknown, .none): state = .notIntegrated
    default: break
    }
    
    return .none
  case .integrationEntitiesUpdated(.failure):
    guard state == .requesting else { return .none }
    
    state = .unknown
    
    return .none
  }
}

