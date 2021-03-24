import AppArchitecture
import Combine
import ComposableArchitecture
import NetworkEnvironment
import NonEmpty
import Types

let stateRestorationReducer: Reducer<AppState, AppAction, SystemEnvironment<AppEnvironment>> = Reducer { state, action, environment in
  switch (state.flow, action) {
  case (.created, .osFinishedLaunching):
    state.flow = .appLaunching
    return
      .merge(
        environment
          .network
          .subscribeToNetworkUpdates()
          .receive(on: environment.mainQueue())
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
                case let .some(.signUp(email)):
                  return Effect(value: AppAction.restoredState(.left(.signUp(email)), network))
                case let .some(.signIn(email)):
                  return Effect(value: AppAction.restoredState(.left(.signIn(email)), network))
                case let .some(.driverID(driverID, publishableKey)):
                  return Effect(value: AppAction.restoredState(.left(.driverID(driverID, publishableKey)), network))
                case let .some(.visits(visits, tabSelection, publishableKey, driverID, pushStatus, experience)):
                  return environment
                    .hyperTrack
                    .makeSDK(publishableKey)
                    .map { (result: (status: SDKStatus, permissions: Permissions)) in
                      switch result.status {
                      case .locked:
                        return AppAction.restoredState(.right(.motionActivityServicesUnavalible), network)
                      case let .unlocked(deviceID, unlockedStatus):
                        
                        return AppAction.restoredState(.left(.visits(visits, tabSelection, publishableKey, driverID, deviceID, unlockedStatus, pushStatus, result.permissions, experience)), network)
                      }
                    }
                }
              }
              .eraseToEffect()
          }
        }
        .receive(on: environment.mainQueue())
        .eraseToEffect()
      )
  case let (.appLaunching, .restoredState(either, n)):
    state.network = n
    
    let stateRestored = Effect<AppAction, Never>(value: AppAction.stateRestored)
    
    switch either {
    case let .left(restoredState):
      switch restoredState {
      case .deepLink:
        state.flow = .signUp(.formFilling(nil, nil, nil, nil, nil, .waitingForDeepLink))
      case let .driverID(driverID, publishableKey):
        state.flow = .driverID(driverID, publishableKey, nil)
      case let .signUp(email):
        state.flow = .signUp(.formFilling(nil, email, nil, nil, nil, nil))
      case .signIn(.none):
        state.flow = .signIn(.editingCredentials(nil, nil))
      case let .signIn(.some(email)):
        state.flow = .signIn(.editingCredentials(.this(email), nil))
      case let .visits(visits, tabSelection, publishableKey, driverID, deviceID, unlockedStatus, pushStatus, permissions, experience):
        let fvs = filterOutOldVisits(environment.date())
        state.flow = .visits(fvs(visits), nil, nil, tabSelection, publishableKey, driverID, deviceID, unlockedStatus, permissions, .none, pushStatus, experience, nil)
        return .merge(
          stateRestored,
          environment
            .hyperTrack
            .subscribeToStatusUpdates()
            .receive(on: environment.mainQueue())
            .eraseToEffect()
            .map(AppAction.statusUpdated)
        )
      
      }
    case .right(.motionActivityServicesUnavalible):
      state.flow = .noMotionServices
    }
    return stateRestored
  default: return .none
  }
}

func filterOutOldVisits(_ now: Date) -> (Set<Visit>) -> (Set<Visit>) {
  {
    $0.filter(visitValid(now: now))
  }
}

func filterOutOldVisit(_ now: Date) -> (Visit?) -> Visit? {
  {
    $0.flatMap { visitValid(now: now)($0) ? $0 : nil }
  }
}

func visitValid(now: Date) -> (Visit) -> Bool {
  { valid($0.createdAt, now: now) }
}

func valid(_ date: Date, now: Date) -> Bool {
  (now.addingTimeInterval(-60 * 60 * 24)...now).contains(date)
}
