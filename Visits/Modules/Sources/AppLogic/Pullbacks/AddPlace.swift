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
  environment: \.errorReporting.capture >>> AddPlaceEnvironment.init(capture:)
)

private let addPlaceStateAffine = /AppState.operational ** \.flow ** /AppFlow.main ** addPlaceMainStateLens

private let addPlaceMainStateLens = Lens<MainState, AddPlaceState>(
  get: { s in
    .init(flow: s.addPlace, history: s.history)
  },
  set: { d in
     \.addPlace *< d.flow <> \.history *< d.history
  }
)

private let addPlaceActionPrism = Prism<AppAction, AddPlaceAction>(
  extract: { a in
    switch a {
    case     .addPlace:                     return .addPlace
    case     .cancelAddPlace:               return .cancelAddPlace
    case     .confirmAddPlaceCoordinate:    return .confirmAddPlaceCoordinate
    case let .updatedAddPlaceCoordinate(c): return .updatedAddPlaceCoordinate(c)
    default:                                return nil
    }
  },
  embed: { a in
    switch a {
    case     .addPlace:                     return .addPlace
    case     .cancelAddPlace:               return .cancelAddPlace
    case     .confirmAddPlaceCoordinate:    return .confirmAddPlaceCoordinate
    case let .updatedAddPlaceCoordinate(c): return .updatedAddPlaceCoordinate(c)
    }
  }
)
