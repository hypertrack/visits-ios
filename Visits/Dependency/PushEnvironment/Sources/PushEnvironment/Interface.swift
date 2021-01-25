import ComposableArchitecture


public struct PushEnvironment {
  public var requestAuthorization: () -> Effect<Never, Never>
  
  public init(
    requestAuthorization: @escaping () -> Effect<Never, Never>
  ) {
    self.requestAuthorization = requestAuthorization
  }
}
