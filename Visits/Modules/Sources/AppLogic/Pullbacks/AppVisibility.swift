import AppArchitecture
import AppVisibilityLogic
import ComposableArchitecture
import Utility
import Types


let appVisibilityP: Reducer<
  AppState,
  AppAction,
  SystemEnvironment<AppEnvironment>
> = appVisibilityReducer.pullback(
  state: appVisibilityStateAffine,
  action: appVisibilityActionPrism,
  environment: constant(())
)

private let appVisibilityStateAffine = /AppState.operational ** \.visibility

private let appVisibilityActionPrism = Prism<AppAction, AppVisibilityAction>(
  extract: { a in
    switch a {
    case let .appVisibilityChanged(v): return .appVisibilityChanged(v)
    default:                           return .none
    }
  },
  embed: { a in
    switch a {
    case let .appVisibilityChanged(v): return .appVisibilityChanged(v)
    }
  }
)
