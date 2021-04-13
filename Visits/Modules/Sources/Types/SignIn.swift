import NonEmpty
import Prelude
import Tagged


public enum SignIn: Equatable {
  case signingIn(Email, Password)
  case editingCredentials(Email?, Password?, Focus?, CognitoError?)
  
  public enum Focus: Equatable { case email, password }
}
