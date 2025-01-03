import ComposableArchitecture
import Types
import Utility
import VisitsLogic

// MARK: - State

public struct TeamState: Equatable {
  public var team: TeamValue?
  public var selectedTeamWorker: TeamWorkerData?

  public init(team: TeamValue? = nil, selectedTeamWorker: TeamWorkerData? = nil) {
    self.team = team
    self.selectedTeamWorker = selectedTeamWorker
  }
}

// MARK: - Action

public enum TeamAction: Equatable {
  case selectTeamWorker(WorkerHandle?)
  case teamUpdated(TeamValue?)
  case teamWorkerVisitsAction(VisitsAction)
  case updateTeam
}

// MARK: - Reducer

public let teamReducer = Reducer<TeamState, TeamAction, Void> { state, action, _ in
  switch action {
  case let .selectTeamWorker(wh):
    if let workerHandle = wh {
      state.selectedTeamWorker = TeamWorkerData(
        from: Date(),
        name: nil,
        selectedVisit: nil,
        to: Date(),
        visits: nil,
        workerHandle: workerHandle
      )
    } else {
      state.selectedTeamWorker = nil
    }
    return .none

  case let .teamUpdated(vs):
    state.team = vs
    return .none

  case let .teamWorkerVisitsAction(a):
      switch a {
      case let .selectVisit(v):
          state.selectedTeamWorker?.selectedVisit = v
      case .updateVisits(_, _, _), .visitsUpdated(_):
          // this state is impossible
          break
      }
    return .none

  case .updateTeam:
    state.team = nil
    return .none
  }
}

public let teamVisitsReducer = Reducer<TeamState, VisitsAction, Void> { state, action, _ in
  switch action {
  case let .visitsUpdated(vd):
    if vd.workerHandle == state.selectedTeamWorker?.workerHandle {
      state.selectedTeamWorker?.visits = vd
    }
    return .none

  case .updateVisits(_, _, _), .selectVisit:
    return .none
  }
}
