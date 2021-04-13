import APIEnvironment
import Combine
import ComposableArchitecture
import NonEmpty
import Prelude
import Types


func verifyEmail(email: Email, code: VerificationCode) -> Effect<Result<PublishableKey, APIError<VerificationError>>, Never> {
  callAPI(
    session: session,
    request: verifyEmailRequest(email: email, code: code),
    success: VerificationSuccess.self,
    failure: VerificationError.self,
    decoder: snakeCaseDecoder
  )
  .map(\.publishableKey)
  .catchToEffect()
}

extension VerificationError: Decodable {
  enum CodingKeys: String, CodingKey {
    case message
    case statusCode
  }
  
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    let message = try values.decode(CognitoError.self, forKey: .message)
    let statusCode = try values.decode(NonEmptyString.self, forKey: .statusCode)
    
    if message.rawValue.rawValue == "User cannot be confirmed. Current status is CONFIRMED",
       statusCode.rawValue == "NotAuthorizedException" {
       self = .alreadyVerified
    } else {
      self = .error(message)
    }
  }
}


struct VerificationSuccess: Decodable {
  let publishableKey: PublishableKey
}

func verifyEmailRequest(email: Email, code: VerificationCode) -> URLRequest {
  let url = URL(string: accountURL + "/account/verify")!
  var request = URLRequest(url: url)
  
  request.httpBody = try! JSONSerialization.data(
    withJSONObject: [
      "email": email.rawValue.rawValue,
      "code": code.string
    ],
    options: JSONSerialization.WritingOptions(rawValue: 0)
  )
  request.httpMethod = "POST"
  request.setValue("Basic \(accountToken)", forHTTPHeaderField: "Authorization")
  request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
  request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
  return request
}
