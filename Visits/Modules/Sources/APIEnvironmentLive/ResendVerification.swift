import APIEnvironment
import Combine
import ComposableArchitecture
import NonEmpty
import Prelude
import Types


func resendVerification(email: Email) -> Effect<Result<ResendVerificationSuccess, APIError<ResendVerificationError>>, Never> {
  callAPI(
    session: session,
    request: resendVerificationRequest(email: email),
    success: AccountCallSuccess.self,
    failure: ResendVerificationError.self,
    decoder: snakeCaseDecoder
  )
  .map(constant(ResendVerificationSuccess()))
  .catchToEffect()
}

extension ResendVerificationError: Decodable {
  enum CodingKeys: String, CodingKey {
    case message
    case statusCode
  }
  
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    let message = try values.decode(CognitoError.self, forKey: .message)
    let statusCode = try values.decode(NonEmptyString.self, forKey: .statusCode)
    
    if message.string == "User is already confirmed.",
       statusCode.rawValue == "InvalidParameterException" {
       self = .alreadyVerified
    } else {
      self = .error(message)
    }
  }
}

func resendVerificationRequest(email: Email) -> URLRequest {
  let url = URL(string: accountURL + "/account/resend_verification")!
  var request = URLRequest(url: url)
  
  request.httpBody = try! JSONSerialization.data(
    withJSONObject: ["email": email.string],
    options: JSONSerialization.WritingOptions(rawValue: 0)
  )
  request.httpMethod = "POST"
  request.setValue("Basic \(accountToken)", forHTTPHeaderField: "Authorization")
  request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
  request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
  return request
}
