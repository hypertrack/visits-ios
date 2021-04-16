import AppArchitecture
import ErrorAlertLogic
import Prelude
import Types


let errorAlertStateLens: Lens<AppState, ErrorAlertState> = .init(
  get: { appState in
    switch appState.alert {
    case let .some(.left(alertState)): return .shown(alertState)
    case .some(.right), .none:         return .dismissed
    }
  },
  set: { errorAlertState in
    { appState in
      switch errorAlertState {
      case let .shown(alertState): return appState |> \AppState.alert *< .left(alertState)
      case     .dismissed:         return appState |> \AppState.alert *< nil
      }
    }
  }
)

let errorAlertActionPrism: Prism<AppAction, ErrorAlertLogicAction> = .init(
  extract: { appAction in
    let displayError = flip(curry(ErrorAlertLogicAction.displayError))
    
    switch appAction {
    case let .signedUp(.failure(e)):
     return e |> toNever <¡> displayError(.signUp)
    case let .autoSignInFailed(e):
      return e |> toNever <¡> displayError(.verification)
    case let .signedIn(.failure(e)):
      return e |> toNever <¡> displayError(.signIn)
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
    case let .displayError(e, .signUp):
    return .signedUp(.failure(fromNever(e)))
    case let .displayError(e, .verification):
      return .autoSignInFailed(fromNever(e))
    case let .displayError(e, .signIn):
      return .signedIn(.failure(fromNever(e)))
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
