import AppArchitecture
import ComposableArchitecture
import Utility
import Types


// MARK: - Action

public enum DriverIDAction: Equatable {
  case driverIDChanged(DriverID?)
  case setDriverID
  case madeSDK(SDKStatusUpdate)
}

// MARK: - Environment

public struct DriverIDEnvironment {
  public var makeSDK: (PublishableKey) -> Effect<SDKStatusUpdate, Never>
  
  public init(makeSDK: @escaping (PublishableKey) -> Effect<SDKStatusUpdate, Never>) {
    self.makeSDK = makeSDK
  }
}

// MARK: - Reducer

public let driverIDReducer = Reducer<
  DriverIDState,
  DriverIDAction,
  SystemEnvironment<DriverIDEnvironment>
> { state, action, environment in
  switch action {
  case let .driverIDChanged(drID):
    guard case .entering = state.status else { return .none }
    
    state.status = .entering(drID)
    
    return .none
  case .setDriverID:
    guard case let .entering(.some(drID)) = state.status else { return .none }
    
    state.status = .entered(drID)
    
    return environment.makeSDK(state.publishableKey)
      .receive(on: environment.mainQueue)
      .map(DriverIDAction.madeSDK)
      .eraseToEffect()
  case .madeSDK:
    return .none
  }
}
