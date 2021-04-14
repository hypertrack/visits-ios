import AppArchitecture
import ErrorAlertLogic
import Prelude


let errorAlertStateLens: Lens<AppState, ErrorAlertState> = .init(
  get: { appState in
    switch appState.alert {
    case let .some(alertState): return .shown(alertState)
    case     .none:             return .dismissed
    }
  },
  set: { errorAlertState in
    { appState in
      switch errorAlertState {
      case let .shown(alertState): return appState |> \AppState.alert *< alertState
      case     .dismissed:         return appState |> \AppState.alert *< nil
      }
    }
  }
)

let errorAlertActionPrism: Prism<AppAction, ErrorAlertLogicAction> = .init(
  extract: { appAction in
    switch appAction {
    case let .signedUp(.failure(.network(urlError))):
      return .displayError(.network(urlError), .signUp)
    case let .signedUp(.failure(.unknown(urlResponse))):
      return .displayError(.unknown(urlResponse), .signUp)
    case let .autoSignInFailed(.network(urlError)):
      return .displayError(.network(urlError), .emailVerification)
    case let .autoSignInFailed(.unknown(urlResponse)):
      return .displayError(.unknown(urlResponse), .emailVerification)
    case let .signedIn(.failure(.network(urlError))):
      return .displayError(.network(urlError), .signIn)
    case let .signedIn(.failure(.unknown(urlResponse))):
      return .displayError(.unknown(urlResponse), .signIn)
    case let .ordersUpdated(.failure(apiError)):
      return .displayError(apiError, .orders)
    case let .placesUpdated(.failure(apiError)):
      return .displayError(apiError, .places)
    case let .historyUpdated(.failure(apiError)):
      return .displayError(apiError, .history)
    case .errorAlert(.ok):
      return .dismissAlert
    default:
      return nil
    }
  },
  embed: { errorAlertAction in
    switch errorAlertAction {
    case let .displayError(.network(urlError), .signUp):
      return .signedUp(.failure(.network(urlError)))
    case let .displayError(.unknown(urlResponse), .signUp):
      return .signedUp(.failure(.unknown(urlResponse)))
    case let .displayError(.network(urlError), .emailVerification),
         let .displayError(.network(urlError), .resendVerification):
      return .autoSignInFailed(.network(urlError))
    case let .displayError(.unknown(urlResponse), .emailVerification),
         let .displayError(.unknown(urlResponse), .resendVerification):
      return .autoSignInFailed(.unknown(urlResponse))
    case let .displayError(.network(urlError), .signIn):
      return .signedIn(.failure(.network(urlError)))
    case let .displayError(.unknown(urlResponse), .signIn):
      return .signedIn(.failure(.unknown(urlResponse)))
    case let .displayError(apiError, .orders):
      return .ordersUpdated(.failure(apiError))
    case let .displayError(apiError, .places):
      return .placesUpdated(.failure(apiError))
    case let .displayError(apiError, .history):
      return .historyUpdated(.failure(apiError))
    case .dismissAlert:
      return .errorAlert(.ok)
    }
  }
)
