import AppArchitecture
import ComposableArchitecture
import ManualReportLogic
import Utility
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
  ** Affine<OperationalState, ManualReportState>(
    extract: { s in
      let manualReportState = { status in ManualReportState(status: status, visibility: s.visibility) }
      
      switch s.alert {
      case     .none:     return manualReportState(.dismissed)
      case let .right(a): return manualReportState(.shown(a))
      default:            return nil
      }
    },
    inject: { d in
      { s in
        switch d.status {
        case     .dismissed: return s |> \.alert *< .none     <> \.visibility *< d.visibility
        case let .shown(a):  return s |> \.alert *< .right(a) <> \.visibility *< d.visibility
        }
      } 
    }
  )

private let manualReportActionPrism = Prism<AppAction, ManualReportAction>(
  extract: { a in
    switch a {
    case     .appVisibilityChanged(.offScreen): return .appWentOffScreen
    case let .errorReportingAlert(aa):          return .alert(aa)
    case     .shakeDetected:                    return .shakeDetected
    default:                                    return nil
    }
  },
  embed: { a in
    switch a {
    case     .appWentOffScreen: return .appVisibilityChanged(.offScreen)
    case let .alert(aa):        return .errorReportingAlert(aa)
    case     .shakeDetected:    return .shakeDetected
    }
  }
)
