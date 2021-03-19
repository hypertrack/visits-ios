import APIEnvironment
import Combine
import ComposableArchitecture
import Credentials
import NonEmpty
import Prelude
import Types

func signUp(
  name: BusinessName,
  email: Email,
  password: Password,
  businessManages: BusinessManages,
  managesFor: ManagesFor
) -> Effect<Result<SignUpError?, APIError>, Never> {
  URLSession.shared.dataTaskPublisher(
    for: signUpRequest(
      name: name,
      email: email,
      password: password,
      businessManages: businessManages,
      managesFor: managesFor
    )
  )
  .map { data, response in
    guard let httpResponse = response as? HTTPURLResponse else { return .failure(.unknown) }
    
    switch httpResponse.statusCode {
    case (200..<300): return .success(nil)
    case 400:
      if let signUpResponse = try? JSONDecoder().decode(SignUpJSONResponse.self, from: data) {
        return .success(.init(rawValue: signUpResponse.message))
      } else {
        return .failure(.unknown)
      }
    default: return .failure(.unknown)
    }
  }
  .mapError { _ in .unknown }
  .catch(Result.failure >>> Just.init(_:))
  .eraseToEffect()
}

struct SignUpJSONResponse: Decodable {
  let message: NonEmptyString
}

func signUpRequest(
  name: BusinessName,
  email: Email,
  password: Password,
  businessManages: BusinessManages,
  managesFor: ManagesFor
) -> URLRequest {
  let url = URL(string: accountURL + "/account/sign_up")!
  var request = URLRequest(url: url)
  var userAttributes: [[String: String]] = []
  userAttributes += [
    cognitoValue(name: "custom:company", value: name.rawValue.rawValue),
    cognitoValue(name: "custom:use_case", value: businessManages.rawValue),
    cognitoValue(name: "custom:state", value: managesFor.rawValue)
  ]
  
  request.httpBody = try! JSONSerialization.data(
    withJSONObject: [
      "email": email.rawValue.rawValue,
      "password": password.rawValue.rawValue,
      "user_attributes": userAttributes
    ],
    options: JSONSerialization.WritingOptions(rawValue: 0)
  )
  request.setValue("Basic \(accountToken)", forHTTPHeaderField: "Authorization")
  request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
  request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
  request.httpMethod = "POST"
  return request
}

func cognitoValue(name: String, value: String) -> [String: String] {
  [
    "Name": name,
    "Value": value
  ]
}
