import ComposableArchitecture
import Types

public struct BranchEnvironment {
  public var subscribeToDeepLinks: () -> Effect<(PublishableKey, DriverID?), Never>
  public var continueUserActivity: (NSUserActivity) -> Effect<Never, Never>
  
  public init(
    subscribeToDeepLinks: @escaping () -> Effect<(PublishableKey, DriverID?), Never>,
    continueUserActivity: @escaping (NSUserActivity) -> Effect<Never, Never>
  ) {
    self.subscribeToDeepLinks = subscribeToDeepLinks
    self.continueUserActivity = continueUserActivity
  }
}
