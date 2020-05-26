import ComposableArchitecture
import Prelude


// MARK: - Action

public enum DeeplinkAction: Equatable {
  case appAppeared
  case receivedDeeplink(String?)
  case signedIn(publishableKey: NonEmptyString)
}

// MARK: - Environment

public struct DeeplinkEnvironment {
  public var checkPublishableKey: () -> Effect<String?, Never>
  public var subscribeToDeeplinkSuccess: () -> Effect<String?, Never>
  
  public init(
    checkPublishableKey: @escaping () -> Effect<String?, Never>,
    subscribeToDeeplinkSuccess: @escaping () -> Effect<String?, Never>
  ) {
    self.checkPublishableKey = checkPublishableKey
    self.subscribeToDeeplinkSuccess = subscribeToDeeplinkSuccess
  }
}

// MARK: - Reducer

public let deeplinkReducer = Reducer<Void, DeeplinkAction, SystemEnvironment<DeeplinkEnvironment>> { _, action, environment in
  switch action {
  case .appAppeared:
    return .merge(
      environment
        .subscribeToDeeplinkSuccess()
        .receive(on: environment.mainQueue())
        .map(DeeplinkAction.receivedDeeplink)
        .eraseToEffect(),
      environment
      .checkPublishableKey()
      .receive(on: environment.mainQueue())
      .map(DeeplinkAction.receivedDeeplink)
      .eraseToEffect()
    )
  case let .receivedDeeplink(publishableKey):
    if let pkString = publishableKey,
      let nonEmptyPK = NonEmptyString(rawValue: pkString) {
      return Effect(value: DeeplinkAction.signedIn(publishableKey: nonEmptyPK))
    }
    return .none
  case .signedIn:
    return .none
  }
}
