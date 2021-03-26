import AppArchitecture
import ComposableArchitecture
import Prelude
import Types

public enum DeepLinkState: Equatable {
  case firstRun
  case firstScreen
  case otherAppState
}

public enum DeepLinkAction: Equatable {
  // Running
  case deepLinkOpened(NSUserActivity)
  case firstRunWaitingComplete
  case restoredStateIsOtherState
  case restoredStateIsFirstRun
  // Sending
  case receivedPublishableKey(PublishableKey)
  case receivedSDKLocked
  case receivedSDKUnlocked(PublishableKey, DriverID, DeviceID, SDKUnlockedStatus, Permissions)
  case receivedSDKStatus(SDKStatus, Permissions)
}

public struct DeepLinkEnvironment {
  public var continueUserActivity: (NSUserActivity) -> Effect<Never, Never>
  public var makeSDK: (PublishableKey) -> Effect<(SDKStatus, Permissions), Never>
  public var setDriverID: (DriverID) -> Effect<Never, Never>
  public var subscribeToDeepLinks: () -> Effect<(PublishableKey, DriverID?), Never>
  public var subscribeToStatusUpdates: () -> Effect<(SDKStatus, Permissions), Never>
  
  public init(
    continueUserActivity: @escaping (NSUserActivity) -> Effect<Never, Never>,
    makeSDK: @escaping (PublishableKey) -> Effect<(SDKStatus, Permissions), Never>,
    setDriverID: @escaping (DriverID) -> Effect<Never, Never>,
    subscribeToDeepLinks: @escaping () -> Effect<(PublishableKey, DriverID?), Never>,
    subscribeToStatusUpdates: @escaping () -> Effect<(SDKStatus, Permissions), Never>
  ) {
    self.continueUserActivity = continueUserActivity
    self.makeSDK = makeSDK
    self.setDriverID = setDriverID
    self.subscribeToDeepLinks = subscribeToDeepLinks
    self.subscribeToStatusUpdates = subscribeToStatusUpdates
  }
}

public let deepLinkReducer = Reducer<DeepLinkState, DeepLinkAction, SystemEnvironment<DeepLinkEnvironment>> { s, a, e in
  switch a {
  case let .deepLinkOpened(ua):
    return e.continueUserActivity(ua)
      .fireAndForget()
  case .firstRunWaitingComplete:
    guard s == .firstRun else { return .none }
    s = .firstScreen
    return .none
  case .restoredStateIsFirstRun:
    return .merge(
      Effect(value: .firstRunWaitingComplete)
      .delay(for: .seconds(3), scheduler: e.mainQueue)
      .eraseToEffect(),
      subscribeToDeepLinks(e)
    )
  case .restoredStateIsOtherState:
    return subscribeToDeepLinks(e)
  case .receivedPublishableKey,
       .receivedSDKLocked,
       .receivedSDKUnlocked,
       .receivedSDKStatus:
    // Cases for a different reducer to handle
    return .none
  }
}

func subscribeToDeepLinks(_ e: SystemEnvironment<DeepLinkEnvironment>) -> Effect<DeepLinkAction, Never> {
  e.subscribeToDeepLinks()
    .receive(on: e.mainQueue)
    .flatMap { (pk: PublishableKey, drID: DriverID?) -> Effect<DeepLinkAction, Never> in
      guard let drID = drID else {
        return Effect(value: .receivedPublishableKey(pk))
      }
      return e.makeSDK(pk)
        .receive(on: e.mainQueue)
        .flatMap { (st: SDKStatus, perm: Permissions) -> Effect<DeepLinkAction, Never> in
          switch st {
          case .locked:
            return Effect(value: .receivedSDKLocked)
          case let .unlocked(devID, uSt):
            return .merge(
              Effect(value: .receivedSDKUnlocked(pk, drID, devID, uSt, perm)),
              e.subscribeToStatusUpdates()
                .receive(on: e.mainQueue)
                .eraseToEffect()
                .map(DeepLinkAction.receivedSDKStatus),
              e.setDriverID(drID)
                .eraseToEffect()
                .fireAndForget()
            )
          }
        }
        .eraseToEffect()
    }
    .eraseToEffect()
}
