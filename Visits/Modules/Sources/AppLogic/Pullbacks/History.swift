import AppArchitecture
import ComposableArchitecture
import HistoryLogic
import Prelude
import Types


let historyP: Reducer<
  AppState,
  AppAction,
  SystemEnvironment<AppEnvironment>
> = historyReducer.pullback(
  state: historyStateAffine,
  action: historyActionPrism,
  environment: constant(())
)

private let historyStateAffine = /AppState.operational ** \.flow ** /AppFlow.main ** \.history

private let historyActionPrism = Prism<AppAction, HistoryAction>(
  extract: { a in
    switch a {
    case let .historyUpdated(.success(h)): return .historyUpdated(h)
    default:                               return nil
    }
  },
  embed: { a in
    switch a {
    case let .historyUpdated(h): return .historyUpdated(.success(h))
    }
  }
)
