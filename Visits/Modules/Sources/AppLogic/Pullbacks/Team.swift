import AppArchitecture
import ComposableArchitecture
import PlacesLogic
import TeamLogic
import Types
import Utility
import VisitsLogic

let teamP: Reducer<
  AppState,
  AppAction,
  SystemEnvironment<AppEnvironment>
> = Reducer.combine(
  teamReducer.pullback(
    state: teamStateAffine,
    action: teamActionPrism,
    environment: constant(())
  ),
  teamVisitsReducer.pullback(
    state: teamStateAffine,
    action: visitsActionPrism,
    environment: constant(())
  )
)

private let teamStateAffine = /AppState.operational ** \.flow ** /AppFlow.main ** teamStateLens

private let teamStateLens = Lens<MainState, TeamState>(
  get: { s in
    .init(
      team: s.team,
      selectedTeamWorker: s.selectedTeamWorker
    )
  },
  set: { d in
    \.team *< d.team <> \.selectedTeamWorker *< d.selectedTeamWorker
  }
)

private let teamActionPrism = Prism<AppAction, TeamAction>(
  extract: { a in
    switch a {
    case let .selectTeamWorker(p): return .selectTeamWorker(p)
    case let .teamUpdated(.success(ps)): return .teamUpdated(ps)
    case let .teamWorkerVisitsAction(a): return .teamWorkerVisitsAction(a)
    case .updateTeam: return .updateTeam
    default: return nil
    }
  },
  embed: { a in
    switch a {
    case let .selectTeamWorker(p): return .selectTeamWorker(p)
    case let .teamUpdated(ps): return .teamUpdated(.success(ps))
    case let .teamWorkerVisitsAction(a): return .teamWorkerVisitsAction(a)
    case .updateTeam: return .updateTeam
    }
  }
)

