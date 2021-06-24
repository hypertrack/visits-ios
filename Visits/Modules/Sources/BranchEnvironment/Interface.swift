import ComposableArchitecture
import Types

public struct BranchEnvironment {
  public var subscribeToDeepLinks: () -> Effect<(PublishableKey, DriverID?), Never>
  public var handleDeepLink: (URL) -> Effect<Never, Never>
  
  public init(
    subscribeToDeepLinks: @escaping () -> Effect<(PublishableKey, DriverID?), Never>,
    handleDeepLink: @escaping (URL) -> Effect<Never, Never>
  ) {
    self.subscribeToDeepLinks = subscribeToDeepLinks
    self.handleDeepLink = handleDeepLink
  }
}
