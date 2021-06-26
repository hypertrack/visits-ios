import ComposableArchitecture
import Types


// MARK: - State

public struct ErrorAlertState: Equatable {
  public enum Status: Equatable {
    case dismissed
    case shown(AlertState<ErrorAlertAction>)
  }
  
  public var status: Status
  public var visibility: AppVisibility
  
  public init(status: Status, visibility: AppVisibility) {
    self.status = status; self.visibility = visibility
  }
}

// MARK: - Action

public enum ErrorAlertLogicAction: Equatable {
  case appWentOffScreen
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
  case .appWentOffScreen, .dismissAlert:
    
    state.status = .dismissed
    
    return .none
  case let .displayError(.network(urlError), _):
    guard state.visibility == .onScreen else { return .none }
    
    state.status = .shown(
      .init(
        title: TextState("Network Issue"),
        message: TextState(urlError.errorDescription.rawValue + tryAgain),
        dismissButton: dismissButton
      )
    )
    
    return .none
  case let .displayError(.api(error, _, _), _):
    guard state.visibility == .onScreen else { return .none }
    
    state.status = .shown(
      .init(
        title: TextState(error.title.string),
        message: TextState(error.detail.string),
        dismissButton: dismissButton
      )
    )
    
    return .none
  case let .displayError(.server(error, _, _), _):
    guard state.visibility == .onScreen else { return .none }
    
    state.status = .shown(
      .init(
        title: TextState("Server Error"),
        message: TextState(error.message.rawValue + tryAgain),
        dismissButton: dismissButton
      )
    )
    
    return .none
  case let .displayError(.unknown(p, _, _), _):
    guard state.visibility == .onScreen else { return .none }
    
    state.status = .shown(
      .init(
        title: TextState("Network Issue"),
        message: TextState("Data corrupted.\n\n\(p.string)\n\nOur engineers are notified about this issue."),
        dismissButton: dismissButton
      )
    )
    
    return .none
  }
}

private let dismissButton = AlertState<ErrorAlertAction>.Button.default(TextState("OK"), send: .ok)
