import AppArchitecture
import DeepLinkLogic
import Prelude


let deepLinkStateAffine: Affine<AppState, DeepLinkState> = .init(
  extract: { s in
    switch s.flow {
    case .firstRun:                                      return .firstRun
    case .signUp(.formFilling(nil, nil, nil, nil, nil)): return .firstScreen
    default:                                             return .otherAppState
    }
  },
  inject: { dls in
    { s in
      switch dls {
      case .firstRun:      return .init(network: s.network, flow: .firstRun)
      case .firstScreen:   return .init(network: s.network, flow: .signUp(.formFilling(nil, nil, nil, nil, nil)))
      case .otherAppState: return s
      }
    }
  }
)

let deepLinkActionAffine: Affine<AppAction, DeepLinkAction> = .init(
  extract: { a in
    switch a {
    case let .deepLinkOpened(ua):                          return .deepLinkOpened(ua)
    case     .restoredState(.left(.deepLink), _):          return .restoredStateIsFirstRun
    case     .restoredState:                               return .restoredStateIsOtherState
    case     .deepLinkFirstRunWaitingComplete:             return .firstRunWaitingComplete
    case let .appHandleDriverIDFlow(pk):                   return .receivedPublishableKey(pk)
    case     .appHandleSDKLocked:                          return .receivedSDKLocked
    case let .appHandleSDKUnlocked(pk, drID, deID, us, p): return .receivedSDKUnlocked(pk, drID, deID, us, p)
    case let .statusUpdated(s, p):                         return .receivedSDKStatus(s, p)
    default:                                               return nil
    }
  },
  inject: { da in
    { a in
      switch (a, da) {
      case let (_,                      .deepLinkOpened(ua)):                         return .deepLinkOpened(ua)
      case let (.restoredState(_, n),   .restoredStateIsFirstRun):                    return .restoredState(.left(.deepLink), n)
      case let (.restoredState(eru, n), .restoredStateIsOtherState):                  return .restoredState(eru, n)
      case     (_,                      .firstRunWaitingComplete):                    return .deepLinkFirstRunWaitingComplete
      case let (_,                      .receivedPublishableKey(pk)):                 return .appHandleDriverIDFlow(pk)
      case     (_,                      .receivedSDKLocked):                          return .appHandleSDKLocked
      case let (_,                      .receivedSDKUnlocked(pk, drID, deID, us, p)): return .appHandleSDKUnlocked(pk, drID, deID, us, p)
      case let (_,                      .receivedSDKStatus(s, p)):                    return .statusUpdated(s, p)
      default:                                                                        return nil
      }
    }
  }
)

func toDeepLinkEnvironment(_ e: SystemEnvironment<AppEnvironment>) -> SystemEnvironment<DeepLinkEnvironment> {
  e.map { e in
    .init(
      continueUserActivity:     e.deepLink.continueUserActivity,
      makeSDK:                  e.hyperTrack.makeSDK,
      setDriverID:              e.hyperTrack.setDriverID,
      subscribeToDeepLinks:     e.deepLink.subscribeToDeepLinks,
      subscribeToStatusUpdates: e.hyperTrack.subscribeToStatusUpdates
    )
  }
}
