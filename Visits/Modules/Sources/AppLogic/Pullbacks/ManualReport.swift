import AppArchitecture
import ComposableArchitecture
import ManualReportLogic
import Prelude
import Types


let manualReportP: Reducer<
  AppState,
  AppAction,
  SystemEnvironment<AppEnvironment>
> = manualReportReducer.pullback(
  state: manualReportStateAffine,
  action: manualReportActionPrism,
  environment: \.hapticFeedback.notifySuccess
    >>> ManualReportEnvironment.init(notifySuccess:)
)


private let manualReportStateAffine: Affine<AppState, ManualReportState> = /AppState.operational
  ** \OperationalState.alert
  ** Prism<Either<AlertState<ErrorAlertAction>, AlertState<ErrorReportingAlertAction>>?, ManualReportState>(
    extract: { alerts in
      switch alerts {
      case     .none:    return .dismissed
      case let .right(a): return .shown(a)
      default:           return nil
      }
    },
    embed: { alert in
      switch alert {
      case     .dismissed: return .none
      case let .shown(a):  return .right(a)
      }
    }
  )

private let manualReportActionPrism = Prism<AppAction, ManualReportAction>(
  extract: { a in
    switch a {
    case     .shakeDetected:           return .shakeDetected
    case let .errorReportingAlert(aa): return .alert(aa)
    default:                           return nil
    }
  },
  embed: { a in
    switch a {
    case     .shakeDetected: return .shakeDetected
    case let .alert(aa):     return .errorReportingAlert(aa)
    }
  }
)
