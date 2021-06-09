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
  state: stateRestorationStatePrism.toAffine(),
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

private let stateRestorationStatePrism = Prism<AppState, StateRestorationState>(
  extract: { d in
    switch d {
    case     .initialState:              return .waitingToStart
    case     .restoringState(.none):     return .restoringState
    case let .restoringState(.some(ss)): return .stateRestored(ss)
    default:                             return nil
    }
  },
  embed: { s in
    switch s {
    case     .waitingToStart:    return .initialState
    case     .restoringState:    return .restoringState(.none)
    case let .stateRestored(ss): return .restoringState(ss)
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
