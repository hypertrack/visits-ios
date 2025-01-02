import ComposableArchitecture
import Types
import Utility

// MARK: - State

public struct VisitsState: Equatable {
  public var visits: VisitsData?
  public var selected: PlaceVisit?
  public var from: Date
  public var to: Date
  public var workerHandle: WorkerHandle

  public init(
    visits: VisitsData?,
    selected: PlaceVisit?,
    from: Date,
    to: Date,
    workerHandle: WorkerHandle
  ) {
    self.visits = visits
    self.selected = selected
    self.from = from
    self.to = to
    self.workerHandle = workerHandle
  }
}

// VisitsAction is in Types because it is used in Team logic

// MARK: - Reducer

public let visitsReducer = Reducer<VisitsState, VisitsAction, Void> { state, action, _ in
  switch action {
  case let .updateVisits(from: from, to: to, wh):
    state.from = from
    state.to = to
    state.visits = nil
      
    return .none
  case let .visitsUpdated(vd):
    if(vd.workerHandle == state.workerHandle) {
      state.visits = vd
    }
      
    return .none

  case let .selectVisit(v):
    state.selected = v
    
    return .none
  }
}
