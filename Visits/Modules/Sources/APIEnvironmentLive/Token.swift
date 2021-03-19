import APIEnvironment
import Combine
import DeviceID
import Foundation
import NonEmpty
import PublishableKey
import Tagged


typealias Token = Tagged<TokenTag, NonEmptyString>
enum TokenTag {}

func getToken(auth publishableKey: PublishableKey, deviceID: DeviceID) -> AnyPublisher<Token, APIError> {
  URLSession.shared.dataTaskPublisher(for: authorizationRequest(auth: publishableKey, deviceID: deviceID))
    .map(\.data)
    .decode(type: Authentication.self, decoder: JSONDecoder())
    .map(\.accessToken)
    .mapError { _ in .unknown }
    .eraseToAnyPublisher()
}

func authorizationRequest(auth publishableKey: PublishableKey, deviceID: DeviceID) -> URLRequest {
  let url = URL(string: "\(internalAPIURL)/authenticate")!
  var request = URLRequest(url: url)
  request.setValue("Basic \(Data(publishableKey.rawValue.rawValue.utf8).base64EncodedString(options: []))", forHTTPHeaderField: "Authorization")
  request.httpBody = try! JSONSerialization.data(
    withJSONObject: ["device_id" : deviceID.rawValue.rawValue],
    options: JSONSerialization.WritingOptions(rawValue: 0)
  )
  request.httpMethod = "POST"
  request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
  request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
  return request
}

struct Authentication: Decodable {
  let accessToken: Token
  
  enum CodingKeys: String, CodingKey {
    case accessToken = "access_token"
  }
}
