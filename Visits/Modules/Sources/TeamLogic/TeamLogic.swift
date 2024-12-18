import ComposableArchitecture
import Types
import Utility


// MARK: - State

public struct TeamState: Equatable {
  public var team: TeamValue?
  public var selectedTeamWorker: WorkerHandle?
  
  public init(team: TeamValue? = nil, selectedTeamWorker: WorkerHandle? = nil) {
    self.team = team
    self.selectedTeamWorker = selectedTeamWorker
  }
}


// MARK: - Action

public enum TeamAction: Equatable {
  case teamUpdated(TeamValue?)
  case selectTeamWorker(WorkerHandle)
}

// MARK: - Reducer

public let teamReducer = Reducer<TeamState, TeamAction, Void> { state, action, _ in
  switch action {
  case let .teamUpdated(vs):
    state.team = vs
    
    return .none

  case let .selectTeamWorker(v):
    state.selectedTeamWorker = v
    
    return .none
  }
}
