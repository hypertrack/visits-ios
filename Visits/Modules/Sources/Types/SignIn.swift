import NonEmpty
import Prelude
import Tagged


public enum SignInState: Equatable {
  case entering(Entering)
  case entered(Entered)
  
  public struct Entering: Equatable {
    public var email: Email?
    public var password: Password?
    public var focus: Focus?
    public var error: CognitoError?
    
    public init(email: Email? = nil, password: Password? = nil, focus: Focus? = nil, error: CognitoError? = nil) {
      self.email = email; self.password = password; self.focus = focus; self.error = error
    }
    
    public enum Focus: Equatable { case email, password }
  }
  
  public struct Entered: Equatable {
    public var email: Email
    public var password: Password
    public var request: Request
   
    public init(email: Email, password: Password, request: Request) {
      self.email = email; self.password = password; self.request = request
    }
    
    public enum Request: Equatable { case inFlight, success(PublishableKey) }
  }
}
