import APIEnvironment
import Coordinate
import Combine
import ComposableArchitecture
import DeviceID
import GeoJSON
import History
import LogEnvironment
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
    case locations
    case activeDuration = "active_duration"
    case inactiveDuration = "inactive_duration"
    case stopDuration = "stop_duration"
    case walkDuration = "walk_duration"
    case steps
    case driveDuration = "drive_duration"
    case distance
  }
  
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    let activeDuration = (try? values.decode(UInt.self, forKey: .activeDuration)) ?? 0
    let inactiveDuration = (try? values.decode(UInt.self, forKey: .inactiveDuration)) ?? 0
    let trackingDuration = activeDuration + inactiveDuration
    let driveDistance = (try? values.decode(UInt.self, forKey: .distance)) ?? 0
    let driveDuration = (try? values.decode(UInt.self, forKey: .driveDuration)) ?? 0
    let steps = (try? values.decode(UInt.self, forKey: .steps)) ?? 0
    let walkDuration = (try? values.decode(UInt.self, forKey: .walkDuration)) ?? 0
    let stopDuration = (try? values.decode(UInt.self, forKey: .stopDuration)) ?? 0
    
    let locationsGeoJSON = try? values.decode(GeoJSON.self, forKey: .locations)
    let coordinates: [Coordinate]
    if let locationsGeoJSON = locationsGeoJSON {
      switch locationsGeoJSON {
      case let .point(coordinate):
        coordinates = [coordinate]
      case let .lineString(.left(c)):
        coordinates = c.rawValue
      case let .lineString(.right(locations)):
        coordinates = locations.rawValue.map(\.coordinate)
      case .lineString(.none), .polygon:
        coordinates = []
      }
    } else {
      coordinates = []
    }
    self.init(
      coordinates: coordinates,
      trackedDuration: trackingDuration,
      driveDistance: driveDistance,
      driveDuration: driveDuration,
      walkSteps: steps,
      walkDuration: walkDuration,
      stopDuration: stopDuration
    )
  }
}
