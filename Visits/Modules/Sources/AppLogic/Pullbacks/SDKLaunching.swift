import AppArchitecture
import ComposableArchitecture
import Utility
import SDKLaunchingLogic
import Types


let sdkLaunchingP: Reducer<
  AppState,
  AppAction,
  SystemEnvironment<AppEnvironment>
> = sdkLaunchingReducer.pullback(
  state: sdkLaunchingStatePrism.toAffine(),
  action: sdkLaunchingActionPrism,
  environment: toSDKLaunchingEnvironment
)

func toStateRestored(_ s: AppState) -> Utility.Unit? {
  switch s {
  case .restoringState(.some): return unit
  default:                     return nil
  }
}

private let sdkLaunchingStatePrism = Prism<AppState, SDKLaunchingState>(
  extract: { s in
    switch s {
    case let .restoringState(.some(ss)): return .init(status: .stateRestored, restoredState: ss)
    case let .launchingSDK(ss):          return .init(status: .launching, restoredState: ss)
    case let .starting(ss, sdk):         return .init(status: .launched(sdk), restoredState: ss)
    default:                             return nil
    }
  },
  embed: { d in
    switch d.status {
    case .stateRestored:     return .restoringState(d.restoredState)
    case .launching:         return .launchingSDK(d.restoredState)
    case let .launched(sdk): return .starting(d.restoredState, sdk)
    }
  }
)

private let sdkLaunchingActionPrism = Prism<AppAction, SDKLaunchingAction>(
  extract: { a in
    switch a {
    case     .generated(.entered(.stateRestored)): return .launch
    case let .statusUpdated(sdk):                  return .subscribed(sdk)
    case let .madeSDK(sdk):                        return .initialized(sdk)
    default:                                       return nil
    }
  },
  embed: { a in
    switch a {
    case     .launch:           return .generated(.entered(.stateRestored))
    case let .subscribed(sdk):  return .statusUpdated(sdk)
    case let .initialized(sdk): return .madeSDK(sdk)
    }
  }
)

private func toSDKLaunchingEnvironment(_ e: SystemEnvironment<AppEnvironment>) -> SystemEnvironment<SDKLaunchingEnvironment> {
  e.map {e in
    .init(
      makeSDK: e.hyperTrack.makeSDK,
      subscribeToStatusUpdates: e.hyperTrack.subscribeToStatusUpdates
    )
  }
}
