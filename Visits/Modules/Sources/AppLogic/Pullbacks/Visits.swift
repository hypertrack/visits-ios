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
        selected: s.selectedVisit,
        from: s.visitsDateFrom,
        to: s.visitsDateTo,
        workerHandle: s.workerHandle
      )  },
  set: { d in
      \.visits *< d.visits
        <> \.selectedVisit *< d.selected
        <> \.visitsDateFrom *< d.from
        <> \.visitsDateTo *< d.to
  }
)


let visitsActionPrism = Prism<AppAction, VisitsAction>(
  extract: { a in
    switch a {
    case let .updateVisits(from: f, to: t, wh): return .updateVisits(from: f, to: t, wh)
    case let .visitsUpdated(.success(vd)):      return .visitsUpdated(vd)
    case let .selectVisit(p):                   return .selectVisit(p)
    default:                                    return nil
    }
  },
  embed: { a in
    switch a {
    case let .updateVisits(from: f, to: t, wh):  return .updateVisits(from: f, to: t, wh)
    case let .visitsUpdated(vd):                 return .visitsUpdated(.success(vd))
    case let .selectVisit(p):                    return .selectVisit(p)
    }
  }
)
