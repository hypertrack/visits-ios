import NonEmpty
import Prelude
import Tagged


public enum SignIn: Equatable {
  case signingIn(Email, Password)
  case editingCredentials(Email?, Password?, Focus?, Error?)
  
  public enum Focus: Equatable { case email, password }
  public typealias Error = Tagged<SignIn, NonEmptyString>
}
