import APIEnvironment
import Combine
import ComposableArchitecture
import NonEmpty
import Prelude
import Types

func signUp(
  name: BusinessName,
  email: Email,
  password: Password,
  businessManages: BusinessManages,
  managesFor: ManagesFor
) -> Effect<Result<SignUpSuccess, APIError<CognitoError>>, Never> {
  callAPI(
    request: signUpRequest(
      name: name,
      email: email,
      password: password,
      businessManages: businessManages,
      managesFor: managesFor
    ),
    success: AccountCallSuccess.self,
    failure: SignUpJSONError.self,
    decoder: snakeCaseDecoder
  )
  .map(constant(SignUpSuccess()))
  .mapError { $0.map(\.message) }
  .catchToEffect()
}


struct AccountCallSuccess: Decodable {
  init() {}
  
  enum CodingKeys: String, CodingKey {
    case message
    case statusCode
  }
  
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    let message = try? values.decode(String.self, forKey: .message)
    let statusCode = try? values.decode(String.self, forKey: .statusCode)
    if let message = message, let statusCode = statusCode, message.isEmpty, statusCode.isEmpty {
      self.init()
    } else {
      throw DecodingError.dataCorrupted(
        .init(
          codingPath: decoder.codingPath,
          debugDescription: "Account call failed"
        )
      )
    }
  }
}

struct SignUpJSONError: Equatable, Decodable {
  let message: CognitoError
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
    cognitoValue(name: "custom:company", value: name.string),
    cognitoValue(name: "custom:use_case", value: businessManages.rawValue),
    cognitoValue(name: "custom:state", value: managesFor.rawValue)
  ]
  
  request.httpBody = try! JSONSerialization.data(
    withJSONObject: [
      "email": email.string,
      "password": password.string,
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
