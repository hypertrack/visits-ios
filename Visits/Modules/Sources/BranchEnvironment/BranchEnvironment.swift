import ComposableArchitecture
import Types
import Validated


public struct BranchEnvironment {
  public var subscribeToDeepLinks: () -> Effect<Validated<DeepLink, NonEmptyString>, Never>
  public var handleDeepLink: (URL) -> Effect<Never, Never>
  
  public init(
    subscribeToDeepLinks: @escaping () -> Effect<Validated<DeepLink, NonEmptyString>, Never>,
    handleDeepLink: @escaping (URL) -> Effect<Never, Never>
  ) {
    self.subscribeToDeepLinks = subscribeToDeepLinks
    self.handleDeepLink = handleDeepLink
  }
}
