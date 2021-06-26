import AppArchitecture
import ComposableArchitecture
import Utility
import StateRestorationLogic
import Types


let stateRestorationP: Reducer<
  AppState,
  AppAction,
  SystemEnvironment<AppEnvironment>
> = stateRestorationReducer.pullback(
  state: stateRestorationStateAffine,
  action: stateRestorationActionPrism,
  environment: toStateRestorationEnvironment
)

private func toStateRestorationEnvironment(_ e: SystemEnvironment<AppEnvironment>) -> SystemEnvironment<StateRestorationLogicEnvironment> {
  e.map { e in
    .init(
      appVersion: e.bundle.appVersion,
      loadState: e.stateRestoration.loadState
    )
  }
}


private let stateRestorationStateAffine = /AppState.launching ** \.stateAndSDK ** Prism<AppLaunching.StateAndSDK?, StateRestorationState>(
  extract: { s in
    switch s {
    case     .none:                      return .waitingToStart
    case     .restoringState(.none):     return .restoringState
    case let .restoringState(.some(rs)): return .stateRestored(rs)
    default:                             return .none
    }
  },
  embed: { d in
    switch d {
    case     .waitingToStart:    return .none
    case     .restoringState:    return .restoringState(.none)
    case let .stateRestored(rs): return .restoringState(rs)
    }
  }
)

private let stateRestorationActionPrism: Prism<AppAction, StateRestorationAction> = .init(
  extract: { appAction in
    switch appAction {
    case     .osFinishedLaunching:  return .osFinishedLaunching
    case let .restoredState(ss, ver, e): return .restoredState(ss, ver, e)
    default:                         return nil
    }
  },
  embed: { stateRestorationAction in
    switch stateRestorationAction {
    case     .osFinishedLaunching:  return .osFinishedLaunching
    case let .restoredState(ss, ver, e): return .restoredState(ss, ver, e)
    }
  }
)
