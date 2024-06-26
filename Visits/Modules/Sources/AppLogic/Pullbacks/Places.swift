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

private let placesStateAffine = /AppState.operational ** \.flow ** /AppFlow.main ** placesStateLens

private let placesStateLens = Lens<MainState, PlacesState>(
  get: { s in
    .init(places: s.places, selected: s.selectedPlace, presentation: s.placesPresentation)
  },
  set: { d in
    \.places *< d.places <> \.selectedPlace *< d.selected <> \.placesPresentation *< d.presentation
  }
)

private let placesActionPrism = Prism<AppAction, PlacesAction>(
  extract: { a in
    switch a {
    case let .changePlacesPresentation(pp): return .changePlacesPresentation(pp)
    case let .placeCreatedWithSuccess(p):   return .placeCreated(p)
    case let .placesUpdated(.success(ps)):  return .placesUpdated(ps)
    case let .selectPlace(p):               return .selectPlace(p)
    default:                                return nil
    }
  },
  embed: { a in
    switch a {
    case let .changePlacesPresentation(pp): return .changePlacesPresentation(pp)
    case let .placeCreated(p):              return .placeCreatedWithSuccess(p)
    case let .placesUpdated(ps):            return .placesUpdated(.success(ps))
    case let .selectPlace(p):               return .selectPlace(p)
    }
  }
)
