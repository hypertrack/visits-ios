import ComposableArchitecture

// MARK: - Action

public enum NotificationAction: Equatable {
  case appAppeared
  case enteredForeground
}

// MARK: - Environment

public struct NotificationEnvironment {
  public var subscribeToEnterForeground: () -> Effect<Void, Never>
  
  public init(subscribeToEnterForeground: @escaping () -> Effect<Void, Never>) {
    self.subscribeToEnterForeground = subscribeToEnterForeground
  }
}

// MARK: - Reducer

public let notificationReducer = Reducer<Void, NotificationAction, SystemEnvironment<NotificationEnvironment>> { _, action, environment in
  switch action {
  case .appAppeared:
    return environment
      .subscribeToEnterForeground()
      .receive(on: environment.mainQueue())
      .map { NotificationAction.enteredForeground }
      .eraseToEffect()
  case .enteredForeground:
    return .none
  }
}
