import APIEnvironment
import Combine
import ComposableArchitecture
import LogEnvironment
import NonEmpty
import Utility
import Types


func getProfile(
  _ token: Token.Value,
  _ dID: DeviceID
) -> Effect<Result<Profile, APIError<Token.Expired>>, Never> {
  logEffect("getProfile")
  
  return callAPI(
    request: deviceRequest(auth: token, deviceID: dID),
    success: Profile.self,
    failure: Token.Expired.self
  )
    .catchToEffect()
}

func deviceRequest(auth token: Token.Value, deviceID: DeviceID) -> URLRequest {
  let url = URL(string: "\(clientURL)/devices/\(deviceID)")!
  var request = URLRequest(url: url)
  request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
  request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
  request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
  request.httpMethod = "GET"
  return request
}

extension Profile: Decodable {
  enum CodingKeys: String, CodingKey {
    case name
    case metadata
  }
  
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    let name = try values.decode(Name.self, forKey: .name)
    let metadata = try values.decode(JSON.Object.self, forKey: .metadata)
    
    self.init(name: name, metadata: metadata)
  }
}
