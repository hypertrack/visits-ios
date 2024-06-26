import APIEnvironment
import Combine
import ComposableArchitecture
import LogEnvironment
import NonEmpty
import Utility
import Types


func getHistory(
  _ token: Token.Value,
  _ dID: DeviceID,
  _ date: Date
) -> Effect<Result<History, APIError<Token.Expired>>, Never> {
  logEffect("getHistory")
  
  return callAPI(
    request: historyRequest(auth: token, deviceID: dID, date: date),
    success: History.self,
    failure: Token.Expired.self
  )
    .catchToEffect()
}

func historyRequest(auth token: Token.Value, deviceID: DeviceID, date: Date) -> URLRequest {
  let timezone = TimeZone.current
  let url = URL(string: "\(clientURL)/devices/\(deviceID)/history/\(historyDate(from: date, timezone: timezone))?timezone=\(timezone.identifier)")!
  var request = URLRequest(url: url)
  request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
  request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
  request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
  request.httpMethod = "GET"
  return request
}

func historyDate(from date: Date, timezone: TimeZone) -> String {
  let formatter = DateFormatter()
  formatter.calendar = .init(identifier: .gregorian)
  formatter.locale = .init(identifier: "en_US_POSIX")
  formatter.timeZone = timezone
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
    
    let activeDuration = try values.decode(UInt.self, forKey: .activeDuration)
    let inactiveDuration = try values.decode(UInt.self, forKey: .inactiveDuration)
    let trackingDuration = activeDuration + inactiveDuration
    let driveDistance = try values.decode(UInt.self, forKey: .distance)
    let driveDuration = try values.decode(UInt.self, forKey: .driveDuration)
    let steps = try values.decode(UInt.self, forKey: .steps)
    let walkDuration = try values.decode(UInt.self, forKey: .walkDuration)
    let stopDuration = try values.decode(UInt.self, forKey: .stopDuration)
    
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
