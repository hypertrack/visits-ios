import AppArchitecture
import ComposableArchitecture
import Utility
import TrackingLogic
import Types


let trackingP: Reducer<
  AppState,
  AppAction,
  SystemEnvironment<AppEnvironment>
> = trackingReducer.pullback(
  state: trackingStateAffine,
  action: trackingActionPrism,
  environment: toTrackingEnvironment
)

private let trackingStateAffine = /AppState.operational ** trackingStateLens

private let trackingStateLens = Lens<OperationalState, TrackingState>(
  get: { s in
//      guard case let .main(m) = s.flow else { return nil } 
      return .init(isRunning: s.sdk.status.isRunning)
  },
  set: { s in
    { d in
      d
    }
  }
)

private let trackingActionPrism = Prism<AppAction, TrackingAction>(
  extract: { a in
    switch a {
    case .startTracking: return .start
    case .stopTracking:  return .stop
    case .clockInToggleTapped: return .toggleTracking
    default: return nil
    }
  },
  embed: { a in
    switch a {
    case .start: return .startTracking
    case .stop:  return .stopTracking
    case .toggleTracking: return .clockInToggleTapped
    }
  }
)

private func toTrackingEnvironment(_ e: SystemEnvironment<AppEnvironment>) -> TrackingEnvironment {
  .init(
    startTracking: e.hyperTrack.startTracking,
    stopTracking: e.hyperTrack.stopTracking
  )
}
