import AppArchitecture
import ComposableArchitecture
import VisitsLogic
import PlacesLogic
import Utility
import Types


let visitsP: Reducer<
  AppState,
  AppAction,
  SystemEnvironment<AppEnvironment>
> = visitsReducer.pullback(
  state: visitsStateAffine,
  action: visitsActionPrism,
  environment: constant(())
)

private let visitsStateAffine = /AppState.operational ** \.flow ** /AppFlow.main ** visitsStateLens

private let visitsStateLens = Lens<MainState, VisitsState>(
  get: { s in
    .init(
      visits: s.visits,
      selected: s.selectedVisit
    )
  },
  set: { d in
    \.visits *< d.visits <> \.selectedVisit *< d.selected
  }
)


private let visitsActionPrism = Prism<AppAction, VisitsAction>(
  extract: { a in
    switch a {
    case let .visitsUpdated(.success(ps)):  return .visitsUpdated(ps)
    case let .selectVisit(p):               return .selectVisit(p)
    default:                                return nil
    }
  },
  embed: { a in
    switch a {
    case let .visitsUpdated(ps):    return .visitsUpdated(.success(ps))
    case let .selectVisit(p):       return .selectVisit(p)
    }
  }
)
