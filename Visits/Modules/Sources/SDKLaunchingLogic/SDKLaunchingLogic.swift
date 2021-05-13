import AppArchitecture
import ComposableArchitecture
import Prelude
import Types


// MARK: - State

public struct SDKLaunchingState: Equatable {
  public var status: Status
  public var restoredState: RestoredState
  
  var publishableKey: PublishableKey? {
    self.restoredState *^? \RestoredState.storage.flow ** /StorageState.Flow.main ** \.3
  }
  
  public enum Status: Equatable {
    case stateRestored
    case launching
    case launched(SDKStatusUpdate)
  }
  
  public init(status: SDKLaunchingState.Status, restoredState: RestoredState) {
    self.status = status; self.restoredState = restoredState
  }
}


// MARK: - Action

public enum SDKLaunchingAction: Equatable {
  case launch
  case subscribed(SDKStatusUpdate)
  case initialized(SDKStatusUpdate)
}

// MARK: - Environment

public struct SDKLaunchingEnvironment {
  public var makeSDK: (PublishableKey) -> Effect<SDKStatusUpdate, Never>
  public var subscribeToStatusUpdates: () -> Effect<SDKStatusUpdate, Never>
  
  public init(
    makeSDK: @escaping (PublishableKey) -> Effect<SDKStatusUpdate, Never>,
    subscribeToStatusUpdates: @escaping () -> Effect<SDKStatusUpdate, Never>
  ) {
    self.makeSDK = makeSDK
    self.subscribeToStatusUpdates = subscribeToStatusUpdates
  }
}

// MARK: - Reducer

public let sdkLaunchingReducer: Reducer<SDKLaunchingState, SDKLaunchingAction, SystemEnvironment<SDKLaunchingEnvironment>> = Reducer { state, action, environment in
  switch action {
  case .launch:
    guard state.status == .stateRestored else { return .none }
    
    state.status = .launching
    
    let subscribe = environment.subscribeToStatusUpdates()
      .removeDuplicates()
      .receive(on: environment.mainQueue)
      .map(SDKLaunchingAction.subscribed)
      .eraseToEffect()
    
    if let pk = state.publishableKey {
      return .merge(
        subscribe,
        environment.makeSDK(pk)
          .receive(on: environment.mainQueue)
          .map(SDKLaunchingAction.initialized)
          .eraseToEffect()
      )
    } else {
      return subscribe
    }
  case let .subscribed(sdk):
    guard state.status == .launching, state.publishableKey == nil else { return .none }
    
    state.status = .launched(sdk)
    
    return .none
  case let .initialized(sdk):
    guard state.status == .launching, state.publishableKey != nil else { return .none }
    
    state.status = .launched(sdk)
    
    return .none
  }
}
