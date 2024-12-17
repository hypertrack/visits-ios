import ComposableArchitecture
import Types
import Utility


// MARK: - State

public struct VisitsState: Equatable {
  public var visits: PlacesVisitsSummary?
    public var selected: Place.Visit?
  
  public init(visits: PlacesVisitsSummary? = nil, selected: Place.Visit? = nil) {
    self.visits = visits
    self.selected = selected
  }
}


// MARK: - Action

public enum VisitsAction: Equatable {
  case visitsUpdated(PlacesVisitsSummary)
  case selectVisit(Place.Visit?)
}

// MARK: - Reducer

public let visitsReducer = Reducer<VisitsState, VisitsAction, Void> { state, action, _ in
  switch action {
  case let .visitsUpdated(vs):
    state.visits = vs
    
    return .none

  case let .selectVisit(v):
    state.selected = v
    
    return .none
  }
}
