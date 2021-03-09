import ComposableArchitecture


public struct PushEnvironment {
  public var requestAuthorization: () -> Effect<Void, Never>
  
  public init(
    requestAuthorization: @escaping () -> Effect<Void, Never>
  ) {
    self.requestAuthorization = requestAuthorization
  }
}
