import ComposableArchitecture
import NonEmpty


public struct PasteboardEnvironment {
  public var copyToPasteboard: (NonEmptyString) -> Effect<Never, Never>
  
  public init(
    copyToPasteboard: @escaping (NonEmptyString) -> Effect<Never, Never>
  ) {
    self.copyToPasteboard = copyToPasteboard
  }
}
