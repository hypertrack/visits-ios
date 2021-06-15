import ComposableArchitecture
import Types


// MARK: - State

public enum ErrorAlertState: Equatable {
  case dismissed
  case shown(AlertState<ErrorAlertAction>)
}

// MARK: - Action

public enum ErrorAlertLogicAction: Equatable {
  case dismissAlert
  case displayError(APIError<Never>, ErrorAlertSource)
}

public enum ErrorAlertSource: Equatable {
  case history
  case orders
  case places
  case signIn
}

// MARK: - Reducer

public let errorAlertReducer = Reducer<ErrorAlertState, ErrorAlertLogicAction, Void> { state, action, environment in
  let tryAgain = "\nPlease try again"
  switch action {
  case .dismissAlert:
    
    state = .dismissed
    
    return .none
  case let .displayError(.network(urlError), _):
    
    state = .shown(
      .init(
        title: TextState("Network Issue"),
        message: TextState(urlError.errorDescription.rawValue + tryAgain),
        dismissButton: .default(TextState("OK"), send: .ok)
      )
    )
    
    return .none
  case let .displayError(.api(error, _, _), _):
    
    state = .shown(
      .init(
        title: TextState(error.title.string),
        message: TextState(error.detail.string),
        dismissButton: .default(TextState("OK"), send: .ok)
      )
    )
    
    return .none
  case let .displayError(.server(error, _, _), _):
    
    state = .shown(
      .init(
        title: TextState("Server Error"),
        message: TextState(error.message.rawValue + tryAgain),
        dismissButton: .default(TextState("OK"), send: .ok)
      )
    )
    
    return .none
  case let .displayError(.unknown(p, _, _), _):
    
    state = .shown(
      .init(
        title: TextState("Network Issue"),
        message: TextState("Data corrupted.\n\n\(p.string)\n\nOur engineers are notified about this issue."),
        dismissButton: .default(TextState("OK"), send: .ok)
      )
    )
    
    return .none
  }
}
