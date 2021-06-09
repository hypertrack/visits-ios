import AppArchitecture
import BlockerLogic
import ComposableArchitecture
import Utility
import Types


let blockerP: Reducer<
  AppState,
  AppAction,
  SystemEnvironment<AppEnvironment>
> = blockerReducer.pullback(
  state: blockerStateAffine,
  action: blockerActionPrism,
  environment: toBlockerEnvironment
)


private let blockerStateAffine = /AppState.operational ** blockerStateLens

private let blockerStateLens = Lens<OperationalState, BlockerState>(
  get: { s in
    .init(locationAlways: s.locationAlways, pushStatus: s.pushStatus)
  },
  set: { s in
    { d in
      d |> \.locationAlways *< s.locationAlways <> \.pushStatus *< s.pushStatus
    }
  }
)

private let blockerActionPrism = Prism<AppAction, BlockerAction>(
  extract: { a in
    switch a {
    case     .openSettings:                        return .openSettings
    case     .requestWhenInUseLocationPermissions: return .requestWhenInUseLocationPermissions
    case     .requestAlwaysLocationPermissions:    return .requestAlwaysLocationPermissions
    case     .requestMotionPermissions:            return .requestMotionPermissions
    case     .requestPushAuthorization:            return .requestPushAuthorization
    case     .userHandledPushAuthorization:        return .userHandledPushAuthorization
    case let .statusUpdated(s):                    return .statusUpdated(s)
    default:                                       return nil
    }
  },
  embed: { a in
    switch a {
    case     .openSettings:                        return .openSettings
    case     .requestWhenInUseLocationPermissions: return .requestWhenInUseLocationPermissions
    case     .requestAlwaysLocationPermissions:    return .requestAlwaysLocationPermissions
    case     .requestMotionPermissions:            return .requestMotionPermissions
    case     .requestPushAuthorization:            return .requestPushAuthorization
    case     .userHandledPushAuthorization:        return .userHandledPushAuthorization
    case let .statusUpdated(s):                    return .statusUpdated(s)
    }
  }
)

private func toBlockerEnvironment(_ e: SystemEnvironment<AppEnvironment>) -> SystemEnvironment<BlockerEnvironment> {
  e.map { e in
    .init(
      openSettings: e.hyperTrack.openSettings,
      requestAlwaysLocationPermissions: e.hyperTrack.requestAlwaysLocationPermissions,
      requestPushAuthorization: e.push.requestAuthorization,
      requestWhenInUseLocationPermissions: e.hyperTrack.requestWhenInUseLocationPermissions,
      requestMotionPermissions: e.hyperTrack.requestMotionPermissions
    )
  }
}
