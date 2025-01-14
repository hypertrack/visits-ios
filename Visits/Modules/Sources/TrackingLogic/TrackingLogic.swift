import ComposableArchitecture


// MARK: - Action

public enum TrackingAction: Equatable { 
  case start
  case stop
  case toggleTracking
}

// MARK: - State

public struct TrackingState {
  public var isRunning: Bool

  public init(isRunning: Bool) {
    self.isRunning = isRunning
  }
}

// MARK: - Environment

public struct TrackingEnvironment {
  public var startTracking: () -> Effect<Never, Never>
  public var stopTracking: () -> Effect<Never, Never>
  
  public init(
    startTracking: @escaping () -> Effect<Never, Never>,
    stopTracking: @escaping () -> Effect<Never, Never>
  ) {
    self.startTracking = startTracking
    self.stopTracking = stopTracking
  }
}

// MARK: - Reducer

public let trackingReducer = Reducer<TrackingState, TrackingAction, TrackingEnvironment> { state, action, environment in
  switch action {
    case .start: 
      return environment.startTracking().fireAndForget()
    case .stop:  
      return environment.stopTracking().fireAndForget()
    case .toggleTracking:
      if state.isRunning {
        return environment.stopTracking().fireAndForget()
      } else {
        return environment.startTracking().fireAndForget()
      }
  }
}
//134
