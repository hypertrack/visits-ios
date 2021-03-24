import APIEnvironment
import Combine
import ComposableArchitecture
import NonEmpty
import Prelude
import Types


func verifyEmail(email: Email, code: VerificationCode) -> Effect<Result<VerificationResponse, APIError>, Never> {
  URLSession.shared.dataTaskPublisher(for: verifyEmailRequest(email: email, code: code))
    .map(\.data)
    .decode(type: VerificationJSONResponse.self, decoder: snakeCaseDecoder)
    .map { response in
      let code = NonEmptyString(rawValue: response.statusCode)
      let message = NonEmptyString(rawValue: response.message)
      let publishableKey = response.publishableKey >>- NonEmptyString.init(rawValue:)
      switch (code, message, publishableKey) {
      case (.some("NotAuthorizedException"), .some("User cannot be confirmed. Current status is CONFIRMED"), _):
        return .success(.alreadyVerified)
      case let (_, _, .some(publishableKey)):
        return .success(.success(PublishableKey(rawValue: publishableKey)))
      case let (.some(code), .none, _):
        return .success(.error(SignUpError(rawValue: code)))
      case let (_, .some(message), _):
        return .success(.error(SignUpError(rawValue: message)))
      case (.none, .none, .none):
        return .failure(.unknown)
      }
    }
    .mapError { _ in .unknown }
    .catch(Result.failure >>> Just.init(_:))
    .eraseToEffect()
}

struct VerificationJSONResponse: Decodable {
  let statusCode: String
  let message: String
  let publishableKey: String?
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
