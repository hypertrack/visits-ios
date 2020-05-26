import ComposableArchitecture


// MARK: - State

public struct LocationState: Equatable {
  public var monitoring: Bool
  public var permissions: LocationPermissions
  
  public init(monitoring: Bool, permissions: LocationPermissions) {
    self.monitoring = monitoring
    self.permissions = permissions
  }
}

public enum LocationPermissions: Equatable {
  case denied
  case disabled
  case granted
  case notRequested
  case restricted
}

// MARK: - Action

public enum LocationAction: Equatable {
  case appAppeared
  case grant(GrantOption)
  case permissionsChanged(LocationPermissions)
  case startMonitoring
  case stopMonitoring
}

public enum GrantOption: Equatable {
  case goToSettings
  case requestPermissions
}

// MARK: - Environment

public struct LocationEnvironment {
  public var locationManagerClient: LocationManagerClient
  public var openSettings: () -> Effect<Never, Never>
  
  public init(
    locationManagerClient: LocationManagerClient,
    openSettings: @escaping () -> Effect<Never, Never>
  ) {
    self.locationManagerClient = locationManagerClient
    self.openSettings = openSettings
  }
}

public struct LocationManagerClient {
  public let startMonitoringPermissions: () -> Effect<LocationPermissions, Never>
  public let requestPermissions: () -> Effect<Never, Never>
  
  public init(
    startMonitoringPermissions: @escaping () -> Effect<LocationPermissions, Never>,
    requestPermissions: @escaping () -> Effect<Never, Never>
  ) {
    self.startMonitoringPermissions = startMonitoringPermissions
    self.requestPermissions = requestPermissions
  }
}

// MARK: - Reducer

public let locationReducer = Reducer<LocationState, LocationAction, SystemEnvironment<LocationEnvironment>> { state, action, environment in
  
  struct AuthorizationChangeCancellationID: Hashable {}
  
  switch action {
  case .appAppeared, .startMonitoring:
  if !state.monitoring {
    state.monitoring = true
    
    return environment
      .locationManagerClient
      .startMonitoringPermissions()
      .receive(on: environment.mainQueue())
      .map(LocationAction.permissionsChanged)
      .eraseToEffect()
      .cancellable(id: AuthorizationChangeCancellationID())
  }
  return .none
  case let .grant(option):
    switch option {
    case .goToSettings:
      return environment.openSettings().fireAndForget()
    case .requestPermissions:
      return environment.locationManagerClient.requestPermissions().fireAndForget()
    }
  case let .permissionsChanged(permissions):
    if state.permissions != permissions {
      state.permissions = permissions
    }
    return .none
  case .stopMonitoring:
    if state.monitoring {
      state.monitoring = false
      return .cancel(id: AuthorizationChangeCancellationID())
    }
    return .none
  }
}
