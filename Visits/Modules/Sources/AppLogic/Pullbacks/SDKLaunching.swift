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
  state: sdkLaunchingStateAffine,
  action: sdkLaunchingActionPrism,
  environment: toSDKLaunchingEnvironment
)

func toStateRestored(_ s: AppState) -> Terminal? {
  switch s {
  case let .launching(l):
    switch l.stateAndSDK {
    case .restoringState(.some): return unit
    default:                     return nil
    }
  default:                       return nil
  }
}

private let sdkLaunchingStateAffine = Affine<AppState, SDKLaunchingState>(
  extract: { s in
    switch s {
    case let .launching(l):
      switch l.stateAndSDK {
      case let .restoringState(.some(rs)): return .init(status: .stateRestored, restoredState: rs)
      case let .launchingSDK(rs):          return .init(status: .launching, restoredState: rs)
      case let .starting(rs, sdk):         return .init(status: .launched(sdk), restoredState: rs)
      default:                             return nil
      }
    default:                               return nil
    }
  },
  inject: { d in
    { s in
      switch s {
      case let .launching(l):
        
        let stateAndSDK: AppLaunching.StateAndSDK
        switch d.status {
        case     .stateRestored: stateAndSDK = .restoringState(d.restoredState)
        case     .launching:     stateAndSDK = .launchingSDK(d.restoredState)
        case let .launched(sdk): stateAndSDK = .starting(d.restoredState, sdk)
        }
        
        return .launching(l |> \.stateAndSDK *< stateAndSDK)
        
      default: return .none
      }
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
