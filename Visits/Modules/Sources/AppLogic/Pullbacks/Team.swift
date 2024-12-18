import AppArchitecture
import ComposableArchitecture
import TeamLogic
import PlacesLogic
import Utility
import Types


let teamP: Reducer<
  AppState,
  AppAction,
  SystemEnvironment<AppEnvironment>
> = teamReducer.pullback(
  state: teamStateAffine,
  action: teamActionPrism,
  environment: constant(())
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
    case let .teamUpdated(.success(ps)):  return .teamUpdated(ps)
    case let .selectTeamWorker(p):               return .selectTeamWorker(p)
    default:                                return nil
    }
  },
  embed: { a in
    switch a {
    case let .teamUpdated(ps):    return .teamUpdated(.success(ps))
    case let .selectTeamWorker(p):       return .selectTeamWorker(p)
    }
  }
)
