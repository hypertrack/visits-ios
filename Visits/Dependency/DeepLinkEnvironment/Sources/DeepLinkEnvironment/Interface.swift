import ComposableArchitecture
import DriverID
import ManualVisitsStatus
import PublishableKey

public struct DeepLinkEnvironment {
  public var subscribeToDeepLinks: () -> Effect<(PublishableKey, DriverID?, ManualVisitsStatus?), Never>
  public var continueUserActivity: (NSUserActivity) -> Effect<Never, Never>
  
  public init(
    subscribeToDeepLinks: @escaping () -> Effect<(PublishableKey, DriverID?, ManualVisitsStatus?), Never>,
    continueUserActivity: @escaping (NSUserActivity) -> Effect<Never, Never>
  ) {
    self.subscribeToDeepLinks = subscribeToDeepLinks
    self.continueUserActivity = continueUserActivity
  }
}
