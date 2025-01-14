import AppArchitecture
import ComposableArchitecture
import Types
import Utility


// MARK: - State

public struct SDKInitializationState: Equatable {
  public var sdk: SDKStatusUpdate
  public var status: Status
  
  public enum Status: Equatable {
    case uninitialized(Email, Password)
    case initialized(Profile, WorkerHandle, Date, Date)
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
  public var setWorkerHandle: (WorkerHandle) -> Effect<Never, Never>

  public init(
    setName: @escaping (Name) -> Effect<Never, Never>,
    setMetadata: @escaping (JSON.Object) -> Effect<Never, Never>,
    setWorkerHandle: @escaping (WorkerHandle) -> Effect<Never, Never>
  ) {
    self.setName = setName
    self.setMetadata = setMetadata
    self.setWorkerHandle = setWorkerHandle
  }
}

// MARK: - Reducer

public let sdkInitializationReducer = Reducer<
  SDKInitializationState,
  SDKInitializationAction,
  SystemEnvironment<SDKInitializationEnvironment>
> { state, action, environment in
  switch action {
  case let .initialize(sdk):
    guard case let .uninitialized(email, _) = state.status else { return .none }
    
    
    let name = emailToName(email)
    let metadata: JSON.Object = ["email": .string(email.string)]
    
    state.sdk = sdk
    let (from, to) = environment.defaultVisitsDatePickerFromTo()
    let workerHandle = WorkerHandle(email.rawValue)
    state.status = .initialized(.init(name: name, metadata: metadata), workerHandle, from, to)

    return .merge(
      environment.setName(name)
        .fireAndForget(),
      environment.setMetadata(metadata)
        .fireAndForget(),
      environment.setWorkerHandle(workerHandle)
        .fireAndForget()
    )
  }
}
