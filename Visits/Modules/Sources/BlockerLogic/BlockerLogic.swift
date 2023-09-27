import AppArchitecture
import ComposableArchitecture
import Utility
import Types


// MARK: - State

public struct BlockerState: Equatable {
  public var locationAlways: LocationAlwaysPermissions
  public var pushStatus: PushStatus
  
  public init(locationAlways: LocationAlwaysPermissions, pushStatus: PushStatus) {
    self.locationAlways = locationAlways; self.pushStatus = pushStatus
  }
}

// MARK: - Action

public enum BlockerAction: Equatable {
  case openSettings
  case requestWhenInUseLocationPermissions
  case requestAlwaysLocationPermissions
  case requestPushAuthorization
  case userHandledPushAuthorization
  case statusUpdated(SDKStatusUpdate)
}

// MARK: - Environment

public struct BlockerEnvironment {
  public var openSettings: () -> Effect<Never, Never>
  public var requestAlwaysLocationPermissions: () -> Effect<Never, Never>
  public var requestPushAuthorization: () -> Effect<Void, Never>
  public var requestWhenInUseLocationPermissions: () -> Effect<Never, Never>
  
  public init(
    openSettings: @escaping () -> Effect<Never, Never>,
    requestAlwaysLocationPermissions: @escaping () -> Effect<Never, Never>,
    requestPushAuthorization: @escaping () -> Effect<Void, Never>,
    requestWhenInUseLocationPermissions: @escaping () -> Effect<Never, Never>
  ) {
    self.openSettings = openSettings
    self.requestAlwaysLocationPermissions = requestAlwaysLocationPermissions
    self.requestPushAuthorization = requestPushAuthorization
    self.requestWhenInUseLocationPermissions = requestWhenInUseLocationPermissions
  }
}

// MARK: - Reducer

public let blockerReducer = Reducer<
  BlockerState,
  BlockerAction,
  SystemEnvironment<BlockerEnvironment>
> { state, action, environment in
  switch action {
  case .openSettings:
    return environment.openSettings().fireAndForget()
  case .requestWhenInUseLocationPermissions:
    return environment.requestWhenInUseLocationPermissions().fireAndForget()
  case .requestAlwaysLocationPermissions:
    state.locationAlways = .requestedAfterWhenInUse
    
    return environment.requestAlwaysLocationPermissions().fireAndForget()
  case .requestPushAuthorization:
    state.pushStatus = .dialogSplash(.waitingForUserAction)
    
    return environment.requestPushAuthorization()
      .receive(on: environment.mainQueue)
      .map(constant(BlockerAction.userHandledPushAuthorization))
      .eraseToEffect()
  case .userHandledPushAuthorization:
    state.pushStatus = .dialogSplash(.shown)
    
    return .none
  case .statusUpdated:
    return .none
  }
}
