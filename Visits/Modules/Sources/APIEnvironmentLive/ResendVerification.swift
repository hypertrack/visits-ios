import APIEnvironment
import Combine
import ComposableArchitecture
import NonEmpty
import Prelude
import Types


func resendVerification(email: Email) -> Effect<Result<ResendVerificationResponse, APIError>, Never> {
  session.dataTaskPublisher(for: resendVerificationRequest(email: email))
    .map(\.data)
    .decode(type: ResendVerificationJSONResponse.self, decoder: snakeCaseDecoder)
    .map { response in
      let code = NonEmptyString(rawValue: response.statusCode)
      let message = NonEmptyString(rawValue: response.message)
      switch (code, message) {
      case (.some("InvalidParameterException"), .some("User is already confirmed.")):
        return .success(.alreadyVerified)
      case (.none, .none):
        return .success(.success)
      case let (.some(code), .none):
        return .success(.error(code))
      case let (_, .some(message)):
        return .success(.error(message))
      }
    }
    .mapError { _ in .unknown }
    .catch(Result.failure >>> Just.init(_:))
    .eraseToEffect()
}

struct ResendVerificationJSONResponse: Decodable {
  let statusCode: String
  let message: String
}

func resendVerificationRequest(email: Email) -> URLRequest {
  let url = URL(string: accountURL + "/account/resend_verification")!
  var request = URLRequest(url: url)
  
  request.httpBody = try! JSONSerialization.data(
    withJSONObject: ["email": email.rawValue.rawValue],
    options: JSONSerialization.WritingOptions(rawValue: 0)
  )
  request.httpMethod = "POST"
  request.setValue("Basic \(accountToken)", forHTTPHeaderField: "Authorization")
  request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
  request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
  return request
}
