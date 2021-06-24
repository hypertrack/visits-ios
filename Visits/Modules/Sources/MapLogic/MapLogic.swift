import ComposableArchitecture
import Types


// MARK: - Action

public enum MapAction: Equatable {
  case regionWillChange
  case regionDidChange
  case enableAutoZoom
}

// MARK: - Reducer

public let mapReducer = Reducer<
  MapState,
  MapAction,
  Void
> { state, action, _ in
  switch action {
  case .regionWillChange, .regionDidChange:
    guard state.autoZoom == .enabled else { return .none }
    
    state.autoZoom = .disabled
    
    return .none
  case .enableAutoZoom:
    guard state.autoZoom == .disabled else { preconditionFailure() }
    
    state.autoZoom = .enabled
    
    return .none
  }
}
