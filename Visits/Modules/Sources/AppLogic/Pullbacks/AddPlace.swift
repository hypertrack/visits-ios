import AddPlaceLogic
import AppArchitecture
import ComposableArchitecture
import Utility
import Types


let addPlaceP: Reducer<
  AppState,
  AppAction,
  SystemEnvironment<AppEnvironment>
> = addPlaceReducer.pullback(
  state: addPlaceStateAffine,
  action: addPlaceActionPrism,
  environment: constant(())
)

private let addPlaceStateAffine = /AppState.operational ** \.flow ** /AppFlow.main ** \.addPlace

private let addPlaceActionPrism = Prism<AppAction, AddPlaceAction>(
  extract: { a in
    switch a {
    case .addPlace: return .addPlace
    default:        return nil
    }
  },
  embed: { a in
    switch a {
    case .addPlace: return .addPlace
    }
  }
)
