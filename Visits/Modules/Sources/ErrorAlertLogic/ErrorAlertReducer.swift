import ComposableArchitecture
import Foundation
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
  case verification
  case history
  case orders
  case places
  case signIn
  case signUp
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
  case let .displayError(.api(error), _):
    state = .shown(
      .init(
        title: TextState(error.title.string),
        message: TextState(error.detail.string),
        dismissButton: .default(TextState("OK"), send: .ok)
      )
    )
    return .none
  case let .displayError(.server(error), _):
    state = .shown(
      .init(
        title: TextState("Server Error"),
        message: TextState(error.message.rawValue + tryAgain),
        dismissButton: .default(TextState("OK"), send: .ok)
      )
    )
    return .none
  case .displayError(.unknown, _):
    state = .shown(
      .init(
        title: TextState("Network Issue"),
        message: TextState("Please try again or update the app to the latest version"),
        dismissButton: .default(TextState("OK"), send: .ok)
      )
    )
    return .none
  }
}
