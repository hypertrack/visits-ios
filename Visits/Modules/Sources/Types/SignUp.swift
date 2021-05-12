import Prelude
import Tagged
import NonEmpty


public enum SignUpState: Equatable {
  case form(Form)
  case questions(Questions)
  case verification(Verification)
  
  public struct Form: Equatable {
    public var status: Status
    public var focus: Focus?
    public var error: CognitoError?
    
    public init(status: Status, focus: Focus? = nil, error: CognitoError? = nil) {
      self.status = status; self.focus = focus; self.error = error
    }
    
    public enum Status: Equatable {
      case filling(Filling)
      case filled(Filled)
      
      public struct Filling: Equatable {
        public var businessName: BusinessName?
        public var email: Email?
        public var password: Password?
        
        public init(businessName: BusinessName? = nil, email: Email? = nil, password: Password? = nil) {
          self.businessName = businessName; self.email = email; self.password = password
        }
      }
      
      public struct Filled: Equatable {
        public var businessName: BusinessName
        public var email: Email
        public var password: Password
        
        public init(businessName: BusinessName, email: Email, password: Password) {
          self.businessName = businessName; self.email = email; self.password = password
        }
      }
    }
    
    public enum Focus: Equatable { case name, email, password }
    
    public static let empty: Self = .init(status: .filling(.init()))
  }
  
  public struct Questions: Equatable {
    public var businessName: BusinessName
    public var email: Email
    public var password: Password
    public var status: Status
    
    public init(businessName: BusinessName, email: Email, password: Password, status: Status) {
      self.businessName = businessName; self.email = email; self.password = password; self.status = status
    }
    
    public enum Status: Equatable {
      case answering(Answering)
      case signingUp(SigningUp)
      
      public struct Answering: Equatable {
        public var businessManages: BusinessManages?
        public var managesFor: ManagesFor?
        public var focus: Focus?
        public var error: CognitoError?
        
        public init(businessManages: BusinessManages? = nil, managesFor: ManagesFor? = nil, focus: Focus? = nil, error: CognitoError? = nil) {
          self.businessManages = businessManages; self.managesFor = managesFor; self.focus = focus; self.error = error
        }
        
        public enum Focus: Equatable { case businessManages, managesFor }
      }
      
      public struct SigningUp: Equatable {
        public var businessManages: BusinessManages
        public var managesFor: ManagesFor
        
        public init(businessManages: BusinessManages, managesFor: ManagesFor) {
          self.businessManages = businessManages; self.managesFor = managesFor
        }
      }
    }
  }
  
  public struct Verification: Equatable {
    public var status: Status
    public var email: Email
    public var password: Password
    
    public init(status: Status, email: Email, password: Password) {
      self.status = status; self.email = email; self.password = password
    }
    
    public enum Status: Equatable {
      case entering(Entering)
      case entered(Entered)
      
      public struct Entering: Equatable {
        public var codeEntry: CodeEntry?
        public var focus: Focus
        public var error: CognitoError?
        public var request: Request?
        
        public init(codeEntry: CodeEntry? = nil, focus: Focus, error: CognitoError? = nil, request: Request? = nil) {
          self.codeEntry = codeEntry; self.focus = focus; self.error = error
        }
        
        public enum CodeEntry: Equatable {
          case one(VerificationCode.Digit)
          case two(VerificationCode.Digit, VerificationCode.Digit)
          case three(VerificationCode.Digit, VerificationCode.Digit, VerificationCode.Digit)
          case four(VerificationCode.Digit, VerificationCode.Digit, VerificationCode.Digit, VerificationCode.Digit)
          case five(VerificationCode.Digit, VerificationCode.Digit, VerificationCode.Digit, VerificationCode.Digit, VerificationCode.Digit)
        }
      }
      
      public struct Entered: Equatable {
        public var verificationCode: VerificationCode
        public var request: Request
        
        public init(verificationCode: VerificationCode, request: Request) {
          self.verificationCode = verificationCode; self.request = request
        }
      }
      
      public enum Request: Equatable {
        case inFlight
        case success(PublishableKey)
      }
      
      public enum Focus: Equatable { case focused, unfocused }
    }
  }
}

public struct ResendVerificationSuccess: Equatable {
  public init() {}
}

public struct SignUpSuccess: Equatable {
  public init() {}
}

public enum ResendVerificationError: Equatable {
  case alreadyVerified
  case error(CognitoError)
}

public enum VerificationError: Equatable {
  case alreadyVerified
  case error(CognitoError)
}
