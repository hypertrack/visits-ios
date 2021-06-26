import AppArchitecture
import AppVisibilityStartupLogic
import ComposableArchitecture
import Utility
import Types


let appVisibilityStartupP: Reducer<
  AppState,
  AppAction,
  SystemEnvironment<AppEnvironment>
> = appVisibilityStartupReducer.pullback(
  state: appVisibilityStartupStateAffine,
  action: appVisibilityStartupActionPrism,
  environment: constant(())
)

private let appVisibilityStartupStateAffine = /AppState.launching ** \.visibility

private let appVisibilityStartupActionPrism = Prism<AppAction, AppVisibilityStartupAction>(
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
