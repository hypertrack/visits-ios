import APIEnvironment
import Coordinate
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
    case insights
    case locations
  }
  
  enum InsightsCodingKeys: String, CodingKey {
    case totalTrackingTime = "total_tracking_time"
    case driveDistance = "drive_distance"
    case driveDuration = "drive_duration"
    case stepCount = "step_count"
    case walkDuration = "walk_duration"
    case stopDuration = "stop_duration"
  }
  
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    let insights = try values.nestedContainer(keyedBy: InsightsCodingKeys.self, forKey: .insights)
    
    let totalTrackingTimeDecoded = try? insights.decode(UInt.self, forKey: .totalTrackingTime)
    let driveDistanceDecoded = try? insights.decode(UInt.self, forKey: .driveDistance)
    let driveDurationDecoded = try? insights.decode(UInt.self, forKey: .driveDuration)
    let stepCountDecoded = try? insights.decode(UInt.self, forKey: .stepCount)
    let walkDurationDecoded = try? insights.decode(UInt.self, forKey: .walkDuration)
    let stopDurationDecoded = try? insights.decode(UInt.self, forKey: .stopDuration)
    
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
      trackedDuration: totalTrackingTimeDecoded ?? 0,
      driveDistance: driveDistanceDecoded ?? 0,
      driveDuration: driveDurationDecoded ?? 0,
      walkSteps: stepCountDecoded ?? 0,
      walkDuration: walkDurationDecoded ?? 0,
      stopDuration: stopDurationDecoded ?? 0
    )
  }
}
