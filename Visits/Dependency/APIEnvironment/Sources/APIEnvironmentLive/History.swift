import APIEnvironment
import Combine
import ComposableArchitecture
import DeviceID
import GeoJSON
import History
import Log
import NonEmpty
import Prelude
import PublishableKey


public func getHistory(
  _ pk: PublishableKey,
  _ dID: DeviceID,
  _ date: Date
) -> Effect<Result<History, APIError>, Never> {
  logEffect("getHistory", failureType: APIError.self)
    .flatMap { getToken(auth: pk, deviceID: dID) }
    .flatMap { getHistoryFromAPI(auth: $0, deviceID: dID, date: date) }
    .map(Result.success)
    .catch(Result.failure >>> Just.init(_:))
    .eraseToEffect()
}

func getHistoryFromAPI(auth token: Token, deviceID: DeviceID, date: Date) -> AnyPublisher<History, APIError> {
  URLSession.shared.dataTaskPublisher(
    for: historyRequest(auth: token, deviceID: deviceID, date: date)
  )
  .map { data, _ in data }
  .decode(type: History.self, decoder: JSONDecoder())
  .mapError { _ in .unknown }
  .eraseToAnyPublisher()
}

func historyRequest(auth token: Token, deviceID: DeviceID, date: Date) -> URLRequest {
  let url = URL(string: "\(clientURL)/devices/\(deviceID)/history/\(historyDate(from: date))?timezone=\(TimeZone.current.identifier)")!
  var request = URLRequest(url: url)
  request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
  request.httpMethod = "GET"
  return request
}

func historyDate(from date: Date) -> String {
  let formatter = DateFormatter()
  formatter.dateFormat = "yyyy-MM-dd"
  return formatter.string(from: date)
}

extension History: Decodable {
  enum CodingKeys: String, CodingKey {
    case distance
    case locations
  }
  
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    let distance = try values.decode(UInt.self, forKey: .distance)
    let locationsGeoJSON = try? values.decode(GeoJSON.self, forKey: .locations)
    if let locationsGeoJSON = locationsGeoJSON {
      switch locationsGeoJSON {
      case let .point(coordinate):
        self.init(coordinates: [coordinate], distance: distance)
      case let .lineString(.left(coordinates)):
        self.init(coordinates: coordinates.rawValue, distance: distance)
      case let .lineString(.right(locations)):
        self.init(coordinates: locations.rawValue.map(\.coordinate), distance: distance)
      case .lineString(.none), .polygon:
        self.init(coordinates: [], distance: distance)
      }
    } else {
      self.init(coordinates: [], distance: distance)
    }
  }
}
