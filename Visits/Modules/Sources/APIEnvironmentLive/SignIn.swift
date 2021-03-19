import APIEnvironment
import Combine
import ComposableArchitecture
import Credentials
import NonEmpty
import Prelude
import PublishableKey


func signIn(_ email: Email, _ password: Password) -> Effect<Result<PublishableKey, APIError>, Never> {
  URLSession.shared.dataTaskPublisher(for: signInRequest(email: email, password: password))
    .map { data, _ in data }
    .decode(type: SignIn.self, decoder: snakeCaseDecoder)
    .map(\.publishableKey >>> Result.success)
    .mapError { _ in .unknown }
    .catch(Result.failure >>> Just.init(_:))
    .eraseToEffect()
}

struct SignIn: Decodable {
  let publishableKey: PublishableKey
}

func signInRequest(email: Email, password: Password) -> URLRequest {
  let url = URL(string: baseURL + "/get_publishable_key")!
  var request = URLRequest(url: url)
  request.httpBody = try! JSONSerialization.data(
    withJSONObject: [
      "username": email.rawValue.rawValue,
      "password": password.rawValue.rawValue
    ],
    options: JSONSerialization.WritingOptions(rawValue: 0)
  )
  request.httpMethod = "POST"
  request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
  request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
  return request
}
