import ComposableArchitecture


// MARK: - Action

public enum TrackingAction: Equatable { case start, stop }

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

public let trackingReducer = Reducer<Void, TrackingAction, TrackingEnvironment> { _, action, environment in
  switch action {
  case .start: return environment.startTracking().fireAndForget()
  case .stop:  return environment.stopTracking().fireAndForget()
  }
}
//134
