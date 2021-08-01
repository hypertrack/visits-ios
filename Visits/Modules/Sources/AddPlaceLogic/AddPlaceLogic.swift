import ComposableArchitecture
import Types
import Utility


// MARK: - Action

public enum AddPlaceAction: Equatable {
  case addPlace
}

// MARK: - Reducer

public let addPlaceReducer = Reducer<AddPlaceState?, AddPlaceAction, Void> { state, action, _ in
  switch action {
  case .addPlace:
    state = .init()
    
    return .none
  }
}
