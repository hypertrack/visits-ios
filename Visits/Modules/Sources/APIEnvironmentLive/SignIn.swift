import APIEnvironment
import Combine
import ComposableArchitecture
import NonEmpty
import Prelude
import Types


func signIn(_ email: Email, _ password: Password) -> Effect<Result<PublishableKey, APIError<CognitoError>>, Never> {
  callAPI(
    request: signInRequest(email: email, password: password),
    success: SignIn.self,
    failure: SignInError.self,
    decoder: snakeCaseDecoder
  )
  .map(\.publishableKey)
  .mapError { $0.map(\.message) }
  .catchToEffect()
}

struct SignIn: Decodable {
  let publishableKey: PublishableKey
}

struct SignInError: Equatable, Decodable {
  let message: CognitoError
}

func signInRequest(email: Email, password: Password) -> URLRequest {
  let url = URL(string: baseURL + "/get_publishable_key")!
  var request = URLRequest(url: url)
  request.httpBody = try! JSONSerialization.data(
    withJSONObject: [
      "username": email.string,
      "password": password.string
    ],
    options: JSONSerialization.WritingOptions(rawValue: 0)
  )
  request.httpMethod = "POST"
  request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
  request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
  return request
}
