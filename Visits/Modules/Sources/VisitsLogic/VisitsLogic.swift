import ComposableArchitecture
import Types
import Utility


// MARK: - State

public struct VisitsState: Equatable {
  public var visits: [Place.Visit]?
  public var selected: Place.Visit?
  public var from: Date
  public var to: Date
  
  public init(
    visits: [Place.Visit]?,
    selected: Place.Visit?,
    from: Date,
    to: Date
  ) {
    self.visits = visits
    self.selected = selected
    self.from = from
    self.to = to
  }
}


// MARK: - Action

public enum VisitsAction: Equatable {
    case updateVisits(from: Date, to: Date)
    case visitsUpdated(VisitsData)
    case selectVisit(Place.Visit?)
}

// MARK: - Reducer

public let visitsReducer = Reducer<VisitsState, VisitsAction, Void> { state, action, _ in
  switch action {
  case let .updateVisits(from, to):
    state.from = from
    state.to = to
    state.visits = nil
      
    return .none
  case let .visitsUpdated(vd):
    state.visits = vd.visits
      
    return .none

  case let .selectVisit(v):
    state.selected = v
    
    return .none
  }
}
