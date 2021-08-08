import ComposableArchitecture
import Types


// MARK: - State

public struct PlacesState: Equatable {
  public var places: Set<Place>
  public var selected: Place?
  
  public init(places: Set<Place>, selected: Place? = nil) { self.places = places; self.selected = selected }
}


// MARK: - Action

public enum PlacesAction: Equatable {
  case placesUpdated(Set<Place>)
  case selectPlace(Place?)
}

// MARK: - Reducer

public let placesReducer = Reducer<PlacesState, PlacesAction, Void> { state, action, _ in
  switch action {
  case let .placesUpdated(ps):
    state.places = ps
    
    return .none
  case let .selectPlace(p):
    state.selected = p
    
    return .none
  }
}
