import AppArchitecture
import ComposableArchitecture
import PlacesLogic
import Utility
import Types


let placesP: Reducer<
  AppState,
  AppAction,
  SystemEnvironment<AppEnvironment>
> = placesReducer.pullback(
  state: placesStateAffine,
  action: placesActionPrism,
  environment: constant(())
)

private let placesStateAffine = /AppState.operational ** \.flow ** /AppFlow.main ** \.places

private let placesActionPrism = Prism<AppAction, PlacesAction>(
  extract: { a in
    switch a {
    case let .placesUpdated(.success(ps)): return .placesUpdated(ps)
    default: return nil
    }
  },
  embed: { a in
    switch a {
    case let .placesUpdated(ps): return .placesUpdated(.success(ps))
    }
  }
)
