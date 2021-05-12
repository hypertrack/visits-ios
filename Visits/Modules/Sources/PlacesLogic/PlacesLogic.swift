import ComposableArchitecture
import Types


// MARK: - Action

public enum PlacesAction: Equatable {
  case placesUpdated(Set<Place>)
}

// MARK: - Reducer

public let placesReducer = Reducer<Set<Place>, PlacesAction, Void> { state, action, _ in
  switch action {
  case let .placesUpdated(ps):
    state = ps
    
    return .none
  }
}
