import AppArchitecture
import ComposableArchitecture
import Prelude
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

private let trackingStateAffine = /AppState.operational ** \.flow ** /AppFlow.main ** .void()

private let trackingActionPrism = Prism<AppAction, TrackingAction>(
  extract: { a in
    switch a {
    case .startTracking: return .start
    case .stopTracking:  return .stop
    default: return nil
    }
  },
  embed: { a in
    switch a {
    case .start: return .startTracking
    case .stop:  return .stopTracking
    }
  }
)

private func toTrackingEnvironment(_ e: SystemEnvironment<AppEnvironment>) -> TrackingEnvironment {
  .init(
    startTracking: e.hyperTrack.startTracking,
    stopTracking: e.hyperTrack.stopTracking
  )
}
