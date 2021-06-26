import AppArchitecture
import ComposableArchitecture
import ErrorAlertLogic
import Utility
import Types


let errorAlertP: Reducer<
  AppState,
  AppAction,
  SystemEnvironment<AppEnvironment>
> = errorAlertReducer.pullback(
  state: errorAlertStateAffine,
  action: errorAlertActionPrism,
  environment: constant(())
)

private let errorAlertStateAffine: Affine<AppState, ErrorAlertState> = /AppState.operational
  ** Affine<OperationalState, ErrorAlertState>(
    extract: { s in
      let errorAlertState = { status in ErrorAlertState(status: status, visibility: s.visibility) }
      
      switch s.alert {
      case     .none:    return errorAlertState(.dismissed)
      case let .left(a): return errorAlertState(.shown(a))
      default:           return nil
      }
    },
    inject: { d in
      { s in
        switch d.status {
        case     .dismissed: return s |> \.alert *< .none    <> \.visibility *< d.visibility
        case let .shown(a):  return s |> \.alert *< .left(a) <> \.visibility *< d.visibility
        }
      }
    }
  )

private let errorAlertActionPrism: Prism<AppAction, ErrorAlertLogicAction> = .init(
  extract: { appAction in
    let displayError = flip(curry(ErrorAlertLogicAction.displayError))
    
    switch appAction {
    case     .appVisibilityChanged(.offScreen):   return .appWentOffScreen
    case let .signedIn(.failure(e)):              return e |> toNever <¡> displayError(.signIn)
    case let .ordersUpdated(.failure(apiError)):  return .displayError(apiError, .orders)
    case let .placesUpdated(.failure(apiError)):  return .displayError(apiError, .places)
    case let .historyUpdated(.failure(apiError)): return .displayError(apiError, .history)
    case     .errorAlert(.ok):                    return .dismissAlert
    default:                                      return nil
    }
  },
  embed: { errorAlertAction in
    switch errorAlertAction {
    case     .appWentOffScreen:                 return .appVisibilityChanged(.offScreen)
    case let .displayError(e, .signIn):         return .signedIn(.failure(fromNever(e)))
    case let .displayError(apiError, .orders):  return .ordersUpdated(.failure(apiError))
    case let .displayError(apiError, .places):  return .placesUpdated(.failure(apiError))
    case let .displayError(apiError, .history): return .historyUpdated(.failure(apiError))
    case     .dismissAlert:                     return .errorAlert(.ok)
    }
  }
)
