import ComposableArchitecture
import Types


public struct NetworkEnvironment {
  public var networkStatus: () -> Effect<Network, Never>
  public var subscribeToNetworkUpdates: () -> Effect<Network, Never>

  public init(
    networkStatus: @escaping () -> Effect<Network, Never>,
    subscribeToNetworkUpdates: @escaping () -> Effect<Network, Never>
  ) {
    self.networkStatus = networkStatus
    self.subscribeToNetworkUpdates = subscribeToNetworkUpdates
  }
}
