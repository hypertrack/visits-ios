import APIEnvironment
import Combine
import Foundation
import NonEmpty
import Tagged
import Types


typealias Token = Tagged<TokenTag, NonEmptyString>
enum TokenTag {}

func getToken(auth publishableKey: PublishableKey, deviceID: DeviceID) -> AnyPublisher<Token, APIError<Never>> {
  callAPI(request: authorizationRequest(auth: publishableKey, deviceID: deviceID), success: Authentication.self)
    .map(\.accessToken)
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
