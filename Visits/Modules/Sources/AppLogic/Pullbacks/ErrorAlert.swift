import AppArchitecture
import ComposableArchitecture
import ErrorAlertLogic
import Prelude
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
  ** \OperationalState.alert
  ** Prism<Either<AlertState<ErrorAlertAction>, AlertState<ErrorReportingAlertAction>>?, ErrorAlertState>(
    extract: { alerts in
      switch alerts {
      case     .none:    return .dismissed
      case let .left(a): return .shown(a)
      default:           return nil
      }
    },
    embed: { alert in
      switch alert {
      case     .dismissed: return .none
      case let .shown(a):  return .left(a)
      }
    }
  )

private let errorAlertActionPrism: Prism<AppAction, ErrorAlertLogicAction> = .init(
  extract: { appAction in
    let displayError = flip(curry(ErrorAlertLogicAction.displayError))
    
    switch appAction {
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
    case let .displayError(e, .signIn):         return .signedIn(.failure(fromNever(e)))
    case let .displayError(apiError, .orders):  return .ordersUpdated(.failure(apiError))
    case let .displayError(apiError, .places):  return .placesUpdated(.failure(apiError))
    case let .displayError(apiError, .history): return .historyUpdated(.failure(apiError))
    case     .dismissAlert:                     return .errorAlert(.ok)
    }
  }
)
