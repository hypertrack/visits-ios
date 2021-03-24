import NonEmpty
import Prelude
import Tagged


public enum SignIn: Equatable {
  case signingIn(Email, Password)
  case editingCredentials(These<Email, Password>?, Either<These<Focus, Error>, ProcessingDeepLink>?)
  
  public enum Focus: Equatable { case email, password }
  public typealias Error = Tagged<SignIn, NonEmptyString>
}
