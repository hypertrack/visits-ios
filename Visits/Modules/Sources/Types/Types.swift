import Prelude
import Tagged
import NonEmpty

public typealias SignUpError = Tagged<SignUpErrorTag, NonEmptyString>
public enum SignUpErrorTag {}


public enum SignUpRequest: Equatable { case inFlight, notSent(SignUpQuestionsFocus?, SignUpError?) }
public enum SignUpQuestionsFocus: Equatable { case businessManages, managesFor }
