import ComposableArchitecture
import NonEmpty
import Types


public struct PasteboardEnvironment {
  public var copyToPasteboard: (NonEmptyString) -> Effect<Never, Never>
  public var verificationCodeFromPasteboard: () -> Effect<VerificationCode?, Never>
  
  public init(
    copyToPasteboard: @escaping (NonEmptyString) -> Effect<Never, Never>,
    verificationCodeFromPasteboard: @escaping () -> Effect<VerificationCode?, Never>
  ) {
    self.copyToPasteboard = copyToPasteboard
    self.verificationCodeFromPasteboard = verificationCodeFromPasteboard
  }
}
