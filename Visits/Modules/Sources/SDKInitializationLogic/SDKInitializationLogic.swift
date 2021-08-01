import ComposableArchitecture
import Types
import Utility


// MARK: - State

public struct SDKInitializationState: Equatable {
  public var sdk: SDKStatusUpdate
  public var status: Status
  
  public enum Status: Equatable {
    case uninitialized(Email, Password)
    case initialized(Profile)
  }
  
  public init(sdk: SDKStatusUpdate, status: SDKInitializationState.Status) {
    self.sdk = sdk; self.status = status
  }
}

// MARK: - Action

public enum SDKInitializationAction: Equatable {
  case initialize(SDKStatusUpdate)
}

// MARK: - Environment

public struct SDKInitializationEnvironment {
  public var setName: (Name) -> Effect<Never, Never>
  public var setMetadata: (JSON.Object) -> Effect<Never, Never>

  public init(
    setName: @escaping (Name) -> Effect<Never, Never>,
    setMetadata: @escaping (JSON.Object) -> Effect<Never, Never>
  ) {
    self.setName = setName
    self.setMetadata = setMetadata
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
    guard case let .uninitialized(email, _) = state.status else { return .none }
    
    
    let name = emailToName(email)
    let metadata: JSON.Object = ["email": .string(email.string)]
    
    state.sdk = sdk
    state.status = .initialized(.init(name: name, metadata: metadata))
    
    return .merge(
      environment.setName(name)
        .fireAndForget(),
      environment.setMetadata(metadata)
        .fireAndForget()
    )
  }
}
