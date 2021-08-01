import AppArchitecture
import ComposableArchitecture
import Utility
import ProfileLogic
import Types


let profileP: Reducer<
  AppState,
  AppAction,
  SystemEnvironment<AppEnvironment>
> = profileReducer.pullback(
  state: profileStateAffine,
  action: profileActionPrism,
  environment: constant(())
)

private let profileStateAffine = /AppState.operational ** \.flow ** /AppFlow.main ** \.profile

private let profileActionPrism = Prism<AppAction, ProfileAction>(
  extract: { a in
    switch a {
    case let .profileUpdated(.success(p)): return .profileUpdated(p)
    default:                               return nil
    }
  },
  embed: { a in
    switch a {
    case let .profileUpdated(p): return .profileUpdated(.success(p))
    }
  }
)
