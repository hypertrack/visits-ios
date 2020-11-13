import Architecture
import Combine
import ComposableArchitecture
import NetworkEnvironment
import NonEmpty
import SDK
import Visit

let stateRestorationReducer: Reducer<AppState, AppAction, SystemEnvironment<AppEnvironment>> = Reducer { state, action, environment in
  switch (state.flow, action) {
  case (.created, .osFinishedLaunching):
    state.flow = .appLaunching
    return
      .merge(
        environment
          .network
          .subscribeToNetworkUpdates()
          .removeDuplicates()
          .map(AppAction.network)
          .eraseToEffect(),
        Publishers.Zip(
          environment
            .network
            .networkStatus(),
          environment
            .hyperTrack
            .checkDeviceTrackability()
        )
        .flatMap { (zipped: (network: Network, untrackableReason: UntrackableReason?)) -> Effect<AppAction, Never> in
          let network = zipped.network
          let untrackableReason = zipped.untrackableReason
          
          switch untrackableReason {
          case let .some(reason):
            return Effect(value: AppAction.restoredState(.right(reason), network))
          case .none:
            return environment
              .stateRestoration
              .loadState()
              .flatMap { storageState -> Effect<AppAction, Never> in
                switch storageState {
                case .none:
                  return Effect(value: AppAction.restoredState(.left(.deepLink), network))
                case let .some(.signIn(email)):
                  return Effect(value: AppAction.restoredState(.left(.signIn(email)), network))
                case let .some(.driverID(driverID, publishableKey, mvs)):
                  return Effect(value: AppAction.restoredState(.left(.driverID(driverID, publishableKey, mvs)), network))
                case let .some(.visits(visits, publishableKey, driverID)):
                  return environment
                    .hyperTrack
                    .makeSDK(publishableKey)
                    .map { (result: (status: SDKStatus, permissions: Permissions)) in
                      switch result.status {
                      case .locked:
                        return AppAction.restoredState(.right(.motionActivityServicesUnavalible), network)
                      case let .unlocked(deviceID, unlockedStatus):
                        
                        return AppAction.restoredState(.left(.visits(visits, publishableKey, driverID, deviceID, unlockedStatus, result.permissions)), network)
                      }
                    }
                }
              }
              .eraseToEffect()
          }
        }
        .eraseToEffect()
      )
  case let (.appLaunching, .restoredState(either, n)):
    state.network = n
    
    let stateRestored = Effect<AppAction, Never>(value: AppAction.stateRestored)
    
    switch either {
    case let .left(restoredState):
      switch restoredState {
      case .deepLink:
        state.flow = .signIn(.editingCredentials(.none, .right(.waitingForDeepLink)))
      case let .driverID(driverID, publishableKey, mvs):
        state.flow = .driverID(driverID, publishableKey, mvs, nil)
      case .signIn(.none):
        state.flow = .signIn(.editingCredentials(nil, nil))
      case let .signIn(.some(email)):
        state.flow = .signIn(.editingCredentials(.this(email), nil))
      case let .visits(visits, publishableKey, driverID, deviceID, unlockedStatus, permissions):
        state.flow = .visits(filterOutOldVisits(visits, now: environment.date()), publishableKey, driverID, deviceID, unlockedStatus, permissions, .none, nil)
        return .merge(
          stateRestored,
          environment
          .hyperTrack
          .subscribeToStatusUpdates()
          .map(AppAction.statusUpdated)
          .eraseToEffect()
        )
      }
    case .right(.motionActivityServicesUnavalible):
      state.flow = .noMotionServices
    }
    return stateRestored
  default: return .none
  }
}

func filterOutOldVisits(_ visits: Visits, now: Date) -> Visits {
  let valid = visitValid(now: now)
  let aValid = assignedVisitValid(now: now)
  switch visits {
  case let .mixed(ms):
    return .mixed(ms.filter(valid))
  case let .assigned(aas):
    return .assigned(aas.filter(aValid))
  case let .selectedMixed(v, ms):
    if valid(v) {
      return .selectedMixed(v, ms.filter(valid))
    } else {
      return .mixed(ms.filter(valid))
    }
  case let .selectedAssigned(a, aas):
    if aValid(a) {
      return .selectedAssigned(a, aas.filter(aValid))
    } else {
      return .assigned(aas.filter(aValid))
    }
  }
}

func visitValid(now: Date) -> (Visit) -> Bool {
  { visit in
    switch visit {
    case let .left(m):
      return valid(m.createdAt, now: now)
    case let .right(a):
      return valid(a.createdAt, now: now)
    }
  }
}

func assignedVisitValid(now: Date) -> (AssignedVisit) -> Bool {
  { valid($0.createdAt, now: now) }
}

func valid(_ date: Date, now: Date) -> Bool {
  (now.addingTimeInterval(-60 * 60 * 24)...now).contains(date)
}
