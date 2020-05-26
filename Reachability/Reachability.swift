import ComposableArchitecture


// MARK: - State

public struct ReachabilityState: Equatable {
  public var isOnline: Bool
  public var monitoring: Bool
  
  public init(isOnline: Bool, monitoring: Bool) {
    self.isOnline = isOnline
    self.monitoring = monitoring
  }
}

// MARK: - Action

public enum ReachabilityAction: Equatable {
  case reachabilityChanged(Bool)
  case startMonitoring
  case stopMonitoring
}

// MARK: - Environment

public struct ReachabilityEnvironment {
  public var startMonitoring: () -> Effect<Bool, Never>
  
  public init(startMonitoring: @escaping () -> Effect<Bool, Never>) {
    self.startMonitoring = startMonitoring
  }
}

// MARK: - Reducer

public let reachabilityReducer = Reducer<ReachabilityState, ReachabilityAction, SystemEnvironment<ReachabilityEnvironment>> { state, action, environment in
  
  struct ReachabilityChangeCancellationID: Hashable {}
  
  switch action {
  case let .reachabilityChanged(isOnline):
    state.isOnline = isOnline
    return .none
  case .startMonitoring:
    if !state.monitoring {
      state.monitoring = true
      return environment
        .startMonitoring()
        .receive(on: environment.mainQueue())
        .map(ReachabilityAction.reachabilityChanged)
        .eraseToEffect()
        .cancellable(id: ReachabilityChangeCancellationID())
    }
    return .none
  case .stopMonitoring:
    if state.monitoring {
      state.monitoring = false
      return .cancel(id: ReachabilityChangeCancellationID())
    }
    return .none
  }
}
