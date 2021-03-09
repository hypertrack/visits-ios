import ComposableArchitecture

public struct HapticFeedbackEnvironment {
  public var notifySuccess: () -> Effect<Never, Never>
  
  public init(notifySuccess: @escaping () -> Effect<Never, Never>) {
    self.notifySuccess = notifySuccess
  }
}
