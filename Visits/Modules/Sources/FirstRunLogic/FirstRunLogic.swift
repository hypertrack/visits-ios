import ComposableArchitecture
import Types


// MARK: - Action

public enum FirstRunAction: Equatable {
  case readyToStart
  case startTracking
}

// MARK: - Reducer

public let firstRunReducer = Reducer<Experience, FirstRunAction, Void> { state, action, _ in
  switch action {
  case .readyToStart:
    guard state == .firstRun else { return .none }
    
    state = .regular
    
    return Effect(value: .startTracking)
  case .startTracking:
    return .none
  }
}
