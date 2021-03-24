import Prelude
import Tagged
import NonEmpty

public typealias SignUpError = Tagged<SignUpErrorTag, NonEmptyString>
public enum SignUpErrorTag {}


public enum SignUpRequest: Equatable { case inFlight, notSent(SignUpQuestionsFocus?, SignUpError?) }
public enum SignUpQuestionsFocus: Equatable { case businessManages, managesFor }

public enum SignUpState: Equatable {
  case formFilled(BusinessName, Email, Password, FormFocus?, SignUpError?)
  case formFilling(BusinessName?, Email?, Password?, FormFocus?, SignUpError?)
  case questions(BusinessName, Email, Password, QuestionsStatus)
  case verification(Verification, Email, Password)
  
  public enum QuestionsStatus: Equatable {
    case signingUp(BusinessManages, ManagesFor, SignUpRequest)
    case answering(Either<BusinessManages, ManagesFor>?, Either<SignUpQuestionsFocus, SignUpError>?)
  }
  
  public enum Verification: Equatable {
    case entered(VerificationCode, Request)
    case entering(CodeEntry?, Focus, SignUpError?)
    
    
    public enum CodeEntry: Equatable {
      case one(VerificationCode.Digit)
      case two(VerificationCode.Digit, VerificationCode.Digit)
      case three(VerificationCode.Digit, VerificationCode.Digit, VerificationCode.Digit)
      case four(VerificationCode.Digit, VerificationCode.Digit, VerificationCode.Digit, VerificationCode.Digit)
      case five(VerificationCode.Digit, VerificationCode.Digit, VerificationCode.Digit, VerificationCode.Digit, VerificationCode.Digit)
    }
    public enum Request: Equatable { case inFlight, notSent(Focus, SignUpError?) }
    
    public enum Focus: Equatable { case focused, unfocused }
  }
  
  public enum FormFocus: Equatable { case name, email, password }
}
