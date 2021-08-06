import AppArchitecture
import ComposableArchitecture
import DeepLinkLogic
import Utility
import Types


let deepLinkP: Reducer<
  AppState,
  AppAction,
  SystemEnvironment<AppEnvironment>
> = deepLinkReducer.pullback(
  state: deepLinkStateAffine,
  action: deepLinkActionPrism,
  environment: toDeepLinkEnvironment
)

private let deepLinkStateAffine = /AppState.operational ** deepLinkStateLens

private let deepLinkActionPrism = Prism<AppAction, DeepLinkAction>(
  extract: { a in
    switch a {
    case     .generated(.entered(.operational)): return .subscribeToDeepLinks
    case     .deepLinkFirstRunWaitingComplete:   return .firstRunWaitingComplete
    case let .deepLinkOpened(u):                 return .deepLinkOpened(u)
    case let .deepLinkFailed(e):                 return .deepLinkFailed(e)
    case let .applyFullDeepLink(d, sdk):         return .applyFullDeepLink(d, sdk)
    case     .cancelAllRequests:                 return .cancelAllRequests
    case     .refreshAllRequests:                return .refreshAllRequests
    default:                                     return nil
    }
  },
  embed: { d in
    switch d {
    case     .subscribeToDeepLinks:              return .generated(.entered(.operational))
    case     .firstRunWaitingComplete:           return .deepLinkFirstRunWaitingComplete
    case let .deepLinkOpened(u):                 return .deepLinkOpened(u)
    case let .deepLinkFailed(e):                 return .deepLinkFailed(e)
    case let .applyFullDeepLink(d, sdk):         return .applyFullDeepLink(d, sdk)
    case     .cancelAllRequests:                 return .cancelAllRequests
    case     .refreshAllRequests:                return .refreshAllRequests
    }
  }
)

private func toDeepLinkEnvironment(_ e: SystemEnvironment<AppEnvironment>) -> SystemEnvironment<DeepLinkEnvironment> {
  e.map { e in
    .init(
      handleDeepLink:       e.deepLink.handleDeepLink,
      makeSDK:              e.hyperTrack.makeSDK,
      setName:              e.hyperTrack.setName,
      setMetadata:          e.hyperTrack.setMetadata,
      subscribeToDeepLinks: e.deepLink.subscribeToDeepLinks
    )
  }
}


private let deepLinkStateLens = Lens<OperationalState, DeepLinkState>(
  get: { .init(flow: $0.flow, sdk: $0.sdk) },
  set: { s in
    { d in
      d |> \.flow *< s.flow
        <> \.sdk *< s.sdk
    }
  }
)
