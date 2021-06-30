import ComposableArchitecture
import Types


public func getToken(_ pk: PublishableKey, _ deID: DeviceID) -> Effect<Result<Token.Value, APIError<Never>>, Never> {
  callAPI(request: authorizationRequest(auth: pk, deviceID: deID), success: Authentication.self)
    .map(\.accessToken)
    .catchToEffect()
}

func authorizationRequest(auth publishableKey: PublishableKey, deviceID: DeviceID) -> URLRequest {
  let url = URL(string: "\(internalAPIURL)/authenticate")!
  var request = URLRequest(url: url)
  request.setValue("Basic \(Data(publishableKey.string.utf8).base64EncodedString(options: []))", forHTTPHeaderField: "Authorization")
  request.httpBody = try! JSONSerialization.data(
    withJSONObject: ["device_id" : deviceID.string],
    options: JSONSerialization.WritingOptions(rawValue: 0)
  )
  request.httpMethod = "POST"
  request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
  request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
  return request
}

struct Authentication: Decodable {
  let accessToken: Token.Value
  
  enum CodingKeys: String, CodingKey {
    case accessToken = "access_token"
  }
}
