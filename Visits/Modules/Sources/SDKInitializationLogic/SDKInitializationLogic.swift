import ComposableArchitecture
import Types


// MARK: - State

public enum SDKInitializationState: Equatable {
  case uninitialized(DriverID, SDKUninitializedSource)
  case initialized(SDKStatusUpdate)
}

public enum SDKUninitializedSource: Equatable {
  case signIn(Password)
  case driverID
}

// MARK: - Action

public enum SDKInitializationAction: Equatable {
  case initialize(SDKStatusUpdate)
}

// MARK: - Environment

public struct SDKInitializationEnvironment {
  public var setDriverID: (DriverID) -> Effect<Never, Never>

  public init(setDriverID: @escaping (DriverID) -> Effect<Never, Never>) {
    self.setDriverID = setDriverID
  }
}

// MARK: - Reducer

public let sdkInitializationReducer = Reducer<
  SDKInitializationState,
  SDKInitializationAction,
  SDKInitializationEnvironment
> { state, action, environment in
  switch action {
  case let .initialize(sdk):
    guard case let .uninitialized(driverID, _) = state else { return .none }
    
    state = .initialized(sdk)
    
    return environment.setDriverID(driverID)
      .fireAndForget()
  }
}
