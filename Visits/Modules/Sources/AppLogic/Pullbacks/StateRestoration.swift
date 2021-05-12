import AppArchitecture
import ComposableArchitecture
import Prelude
import StateRestorationLogic
import Types


let stateRestorationP: Reducer<
  AppState,
  AppAction,
  SystemEnvironment<AppEnvironment>
> = stateRestorationReducer.pullback(
  state: stateRestorationStatePrism.toAffine(),
  action: stateRestorationActionPrism,
  environment: \.stateRestoration.loadState
    >>> StateRestorationLogicEnvironment.init(loadState:)
)

let stateRestorationStatePrism = Prism<AppState, StateRestorationState>(
  extract: { d in
    switch d {
    case     .waitingToFinishLaunching:  return .waitingToStart
    case     .restoringState(.none):     return .restoringState
    case let .restoringState(.some(ss)): return .stateRestored(ss)
    default:                             return nil
    }
  },
  embed: { s in
    switch s {
    case     .waitingToStart:    return .waitingToFinishLaunching
    case     .restoringState:    return .restoringState(.none)
    case let .stateRestored(ss): return .restoringState(ss)
    }
  }
)

let stateRestorationActionPrism: Prism<AppAction, StateRestorationAction> = .init(
  extract: { appAction in
    switch appAction {
    case     .osFinishedLaunching:  return .osFinishedLaunching
    case let .restoredState(state): return .restoredState(state)
    default:                         return nil
    }
  },
  embed: { stateRestorationAction in
    switch stateRestorationAction {
    case     .osFinishedLaunching:  return .osFinishedLaunching
    case let .restoredState(state): return .restoredState(state)
    }
  }
)
