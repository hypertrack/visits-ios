import ComposableArchitecture

import Prelude

// MARK: - State

public struct RestorationState {
  public var completedDeliveries: [NonEmptyString]
  
  public init(completedDeliveries: [NonEmptyString]) {
    self.completedDeliveries = completedDeliveries
  }
}

// MARK: - Action

public enum RestorationAction: Equatable {
  case obtainedPublishableKey(NonEmptyString)
  case saveCompletedDeliveries
  case updatedDriverID(NonEmptyString)
}

// MARK: - Environment

public struct RestorationEnvironment {
  public var saveCompletedDeliveries: ([NonEmptyString]) -> Effect<Never, Never>
  public var saveDriverID: (NonEmptyString) -> Effect<Never, Never>
  public var savePublishableKey: (NonEmptyString) -> Effect<Never, Never>
  
  public init(
    saveCompletedDeliveries: @escaping ([NonEmptyString]) -> Effect<Never, Never>,
    saveDriverID: @escaping (NonEmptyString) -> Effect<Never, Never>,
    savePublishableKey: @escaping (NonEmptyString) -> Effect<Never, Never>
  ) {
    self.saveCompletedDeliveries = saveCompletedDeliveries
    self.saveDriverID = saveDriverID
    self.savePublishableKey = savePublishableKey
  }
}


// MARK: - Reducer

public let restorationReducer = Reducer<RestorationState, RestorationAction, SystemEnvironment<RestorationEnvironment>> { state, action, environment in
  switch action {
  case .saveCompletedDeliveries:
    return environment
      .saveCompletedDeliveries(state.completedDeliveries)
      .fireAndForget()
  case let .obtainedPublishableKey(pk):
    return environment
      .savePublishableKey(pk)
      .fireAndForget()
  case let .updatedDriverID(driverID):
    return environment
      .saveDriverID(driverID)
      .fireAndForget()
  }
}
