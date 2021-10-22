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
      case let .errorAlert(a): return errorAlertState(.shown(a))
      default:           return nil
      }
    },
    inject: { d in
      { s in
        switch d.status {
        case     .dismissed: return s |> \.alert *< .none    <> \.visibility *< d.visibility
        case let .shown(a):  return s |> \.alert *< .errorAlert(a) <> \.visibility *< d.visibility
        }
      }
    }
  )

private let errorAlertActionPrism: Prism<AppAction, ErrorAlertLogicAction> = .init(
  extract: { appAction in
    switch appAction {
    case let .appVisibilityChanged(v):                  return .appVisibilityChanged(v)
    case let .deepLinkFailed(e):                        return .deepLinkFailed(e)
    case let .errorAlert(a):                            return .errorAlert(a)
    case let .historyUpdated(r):                        return .historyUpdated(r)
    case let .integrationEntitiesUpdatedWithFailure(e): return .integrationEntitiesUpdatedWithFailure(e)
    case let .orderCancelFinished(o, r):                return .orderCancelFinished(o, r)
    case let .orderCompleteFinished(o, r):              return .orderCompleteFinished(o, r)
    case let .orderSnoozeFinished(o, r):                return .orderSnoozeFinished(o, r)
    case let .orderUnsnoozeFinished(o, r):              return .orderUnsnoozeFinished(o, r)
    case let .tripUpdated(r):                           return .tripUpdated(r)
    case let .placeCreatedWithFailure(e):               return .placeCreatedWithFailure(e)
    case let .placesUpdated(r):                         return .placesUpdated(r)
    case let .profileUpdated(r):                        return .profileUpdated(r)
    case let .signedIn(r):                              return .signedIn(r)
    case let .tokenUpdated(r):                          return .tokenUpdated(r)
    default:                                            return nil
    }
  },
  embed: { errorAlertAction in
    switch errorAlertAction {
    case let .appVisibilityChanged(v):                  return .appVisibilityChanged(v)
    case let .deepLinkFailed(e):                        return .deepLinkFailed(e)
    case let .errorAlert(a):                            return .errorAlert(a)
    case let .historyUpdated(r):                        return .historyUpdated(r)
    case let .integrationEntitiesUpdatedWithFailure(e): return .integrationEntitiesUpdatedWithFailure(e)
    case let .orderCancelFinished(o, r):                return .orderCancelFinished(o, r)
    case let .orderCompleteFinished(o, r):              return .orderCompleteFinished(o, r)
    case let .orderSnoozeFinished(o, r):                return .orderSnoozeFinished(o, r)
    case let .orderUnsnoozeFinished(o, r):              return .orderUnsnoozeFinished(o, r)
    case let .tripUpdated(r):                           return .tripUpdated(r)
    case let .placeCreatedWithFailure(e):               return .placeCreatedWithFailure(e)
    case let .placesUpdated(r):                         return .placesUpdated(r)
    case let .profileUpdated(r):                        return .profileUpdated(r)
    case let .signedIn(r):                              return .signedIn(r)
    case let .tokenUpdated(r):                          return .tokenUpdated(r)
    }
  }
)
