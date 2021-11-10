import APIEnvironment
import Combine
import ComposableArchitecture
import Foundation
import LogEnvironment
import NonEmpty
import Utility
import Tagged
import Types


func getPlaces(_ token: Token.Value, _ deID: DeviceID, _ pk: PublishableKey, _ today: Date, _ c: Calendar) -> Effect<Result<PlacesSummary, APIError<Token.Expired>>, Never> {
  logEffect("getPlaces")

  return Publishers.Zip(
    getNearestGeofences(auth: token, deviceID: deID),
    callAPI(
      request: getVisits(deviceID: deID, publishableKey: pk, today: today, calendar: c),
      success: VisitSummary.self
    )
      .mapError(fromNever)
      .eraseToAnyPublisher()
  )
  .flatMap(askForMissingGeofences(token: token, deviceID: deID))
  .map(toPlacesSummary(requestedAt: today))
  .catchToEffect()
}

func askForMissingGeofences(token: Token.Value, deviceID: DeviceID) -> (Set<Geofence>, VisitSummary) -> AnyPublisher<(Set<Geofence>, VisitSummary), APIError<Token.Expired>> {
  { geofences, summary in
    guard let missingGeofenceIDs = NonEmptySet(rawValue: geofencesNotInNearby(nearbyGeofences: geofences, summary: summary))
    else  {
      return Just((geofences, summary))
        .setFailureType(to: APIError<Token.Expired>.self)
        .eraseToAnyPublisher()
    }
    return Publishers.MergeMany(missingGeofenceIDs.rawValue.map(getGeofence(auth: token, deviceID: deviceID)))
      .collect()
      .map { missingGeofences in
        (Set(missingGeofences).union(geofences), summary)
      }
      .eraseToAnyPublisher()
  }
}

func getGeofence(auth token: Token.Value, deviceID: DeviceID) -> (NonEmptyString) -> AnyPublisher<Geofence, APIError<Token.Expired>> {
  { geofenceID in
    callAPI(
      request: getGeofence(auth: token, deviceID: deviceID, geofenceID: geofenceID),
      success: Geofence.self,
      failure: Token.Expired.self
    )
  }
}

func geofencesNotInNearby(nearbyGeofences geofences: Set<Geofence>, summary: VisitSummary) -> Set<NonEmptyString> {
  summary.days
    .compactMap(identity)
    .compactMap { visitedDay in
      visitedDay.geofenceMarkers
        .compactMap { marker in
          if geofences.contains(where: { $0.id == marker.geofenceID }) {
            return nil
          } else {
            return marker.geofenceID
          }
        }
    }
    .flatMap(identity)
    |> Set.init
}



func toPlacesSummary(requestedAt: Date) -> (Set<Geofence>,  VisitSummary) -> PlacesSummary {
  { geofences, summary in
    .init(
      places: geofences
        .map { g in
          g |> \.markers *< summary.days
            .compactMap(identity)
            .flatMap { day in
              day.geofenceMarkers.filter { marker in
                marker.geofenceID == g.id
              }
            }
        }
        .map(Place.init(geofence:))
      |> Set.init,
      requestedAt: requestedAt,
      driveDistancesForDaysWithVisits: (
        summary.days
          .map { day in
            switch day {
            case     .none:    return .none
            case let .some(d): return d.driveDistance
            }
          }
        |> NonEmptyArray.init(rawValue:)
      )!
    )
  }
}

func getNearestGeofences(auth token: Token.Value, deviceID: DeviceID) -> AnyPublisher<Set<Geofence>, APIError<Token.Expired>> {
  callAPI(
    request: geofencesRequest(auth: token, deviceID: deviceID, paginationToken: nil),
    success: GeofencePage.self,
    failure: Token.Expired.self
  )
  .map { gs in
    gs.geofences.filter { g in
      g.deviceID == accountGeofenceDeviceID
   || g.deviceID == deviceID.rawValue
    }
  }
  .map(Set.init)
  .eraseToAnyPublisher()
}

func geofencesRequest(auth token: Token.Value, deviceID: DeviceID, paginationToken: PaginationToken?) -> URLRequest {
  var components = URLComponents()
  components.scheme = "https"
  components.host = "live-app-backend.htprod.hypertrack.com"
  components.path = "/client/geofences"
  components.queryItems = [
    URLQueryItem(name: "include_archived", value: "false"),
    URLQueryItem(name: "sort_nearest", value: "true"),
    URLQueryItem(name: "include_markers", value: "false"),
    URLQueryItem(name: "limit", value: "100")
  ]
  if let paginationToken = paginationToken, let queryItems = components.queryItems {
    components.queryItems = queryItems + [
      URLQueryItem(name: "pagination_token", value: "\(paginationToken)")
    ]
  }
  
  var request = URLRequest(url: components.url!)
  request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
  request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
  request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
  request.httpMethod = "GET"
  return request
}

func dateTime(isFrom: Bool, day: Int, today: Date, calendar: Calendar) -> String {
  DateFormatter.iso8601MillisecondsDateFormatter.string(
    from: calendar.date(
      byAdding: .day,
      value: isFrom ? -day : -(day - 1),
      to: calendar.date(
        from: calendar.dateComponents(
          [.timeZone, .year, .month, .day],
          from: today)
      )!
    )!
  )
}

func toDateTime(for day: Int, from today: Date, calendar: Calendar) -> String {
  dateTime(isFrom: false, day: day, today: today, calendar: calendar)
}

func fromDateTime(for day: Int, from today: Date, calendar: Calendar) -> String {
  dateTime(isFrom: true, day: day, today: today, calendar: calendar)
}

func getVisits(deviceID: DeviceID, publishableKey: PublishableKey, today: Date, calendar: Calendar) -> URLRequest {
  let url = URL(string: graphQLURL.rawValue)!
  var request = URLRequest(url: url)
  request.setValue(graphQLKey.rawValue, forHTTPHeaderField: "X-Api-Key")
  request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
  request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
  request.httpMethod = "POST"

  var query = "query VisitHistory($publishable_key:ID!,$device_id:ID!){"

  for dayNumber in 0...59 {
    query += #"day\#(dayNumber):getDeviceHistory(device_id:$device_id,from_datetime:"\#(fromDateTime(for: dayNumber, from: today, calendar: calendar))",publishable_key:$publishable_key,to_datetime:"\#(toDateTime(for: dayNumber, from: today, calendar: calendar))"){...visitHistory}"#
  }

  query += "}fragment visitHistory on DeviceHistory{drive_distance geofence_markers{id exit{recorded_at}route_to{distance duration}arrival{recorded_at}geofence{geofence_id}}}"

  request.httpBody = try! JSONSerialization.data(
    withJSONObject: [
      "query": query,
      "variables": [
        "device_id": deviceID.string,
        "publishable_key": publishableKey.string
      ]
    ],
    options: JSONSerialization.WritingOptions(rawValue: 0)
  )
  return request
}

func getGeofence(auth token: Token.Value, deviceID: DeviceID, geofenceID: NonEmptyString) -> URLRequest {
  let url = URL(string: "\(clientURL)/geofences/\(geofenceID.rawValue)")!

  var request = URLRequest(url: url)
  request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
  request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
  request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
  request.httpMethod = "GET"
  return request
}

struct VisitSummary {
  var days: [VisitedDay?]
}

struct VisitedDay {
  var driveDistance: UInt
  var geofenceMarkers: NonEmptyArray<GeofenceMarker>
}

extension VisitSummary: Decodable {
  enum CodingKeys: String, CodingKey {
    case data
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    let data = try values.nestedContainer(keyedBy: DynamicKey.self, forKey: .data)

    var mDays: [VisitedDay?] = []

    for day in 0...59 {
      let day = try data.decode(Day.self, forKey: .init(stringValue: "day\(day)")!)
      if let neGeofenceMarkers = NonEmptyArray(rawValue: day.geofenceMarkers) {
        mDays.append(
          .init(
            driveDistance: day.driveDistance,
            geofenceMarkers: neGeofenceMarkers
          )
        )
      } else {
        mDays.append(nil)
      }
    }

    days = mDays
  }
}

struct Day {
  var driveDistance: UInt
  var geofenceMarkers: [GeofenceMarker]
}

extension Day: Decodable {
  enum CodingKeys: String, CodingKey {
    case driveDistance = "drive_distance"
    case geofenceMarkers = "geofence_markers"
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    driveDistance = try values.decode(UInt.self, forKey: .driveDistance)

    geofenceMarkers = try values.decode([GeofenceMarker].self, forKey: .geofenceMarkers)
  }
}


extension Place {
  init(geofence: Geofence) {
    let id: Place.ID = wrap(geofence.id)
    let address: Address = .init(string: geofence.address)
    let createdAt: Place.CreatedTimestamp = wrap(geofence.createdAt)
    let metadata: [Place.Name : Place.Contents] = wrapDictionary(geofence.metadata)
    let shape = geofence.shape
       
    func wrapRoute(_ routeTo: RouteTo) -> Place.Route {
      .init(
        distance: wrap(routeTo.distance),
        duration: wrap(routeTo.duration),
        idleTime: 0
      )
    }
    
    let visitOrExit: [Either<Place.Visit, Place.Entry>] = geofence.markers.map { marker in
      switch marker.visitStatus {
      case let .entered(en):
        return .right(
          .init(
            id: wrap(marker.id),
            entry: wrap(en),
            route: marker.routeTo.map(wrapRoute)
          )
        )
      case let .visited(en, ex):
        return .left(
          .init(
            id: wrap(marker.id),
            entry: wrap(en),
            exit: wrap(ex),
            route: marker.routeTo.map(wrapRoute)
          )
        )
      }
    }

    let currentlyInside: Place.Entry? = visitOrExit.compactMap(eitherRight).first
    let visits: [Place.Visit] = visitOrExit.compactMap(eitherLeft)
    
    self.init(
      id: id,
      address: address,
      createdAt: createdAt,
      currentlyInside: currentlyInside,
      metadata: metadata,
      shape: shape,
      visits: visits
    )
  }
}


func wrapDictionary<A, B, C, D>(_ dict: Dictionary<A, B>) -> Dictionary<Tagged<C, A>, Tagged<D, B>> {
  Dictionary(uniqueKeysWithValues: dict.map { (wrap($0), wrap($1)) })
}

func wrap<Destination, Value>(_ value: Value) -> Tagged<Destination, Value> {
  .init(rawValue: value)
}

struct GeofencePage {
  let geofences: [Geofence]
  let paginationToken: PaginationToken?
}

struct Geofence {
  let id: NonEmptyString
  let deviceID: NonEmptyString
  let address: String
  let createdAt: Date
  let metadata: [NonEmptyString: NonEmptyString]
  let shape: GeofenceShape
  var markers: [GeofenceMarker]
}

extension Geofence: Hashable {
  static func == (lhs: Geofence, rhs: Geofence) -> Bool {
    lhs.id == rhs.id
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

extension GeofencePage: Decodable {
  enum CodingKeys: String, CodingKey {
    case data
    case paginationToken = "pagination_token"
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    geofences = try values.decode([Geofence].self, forKey: .data)
    paginationToken = try? values.decodeIfPresent(PaginationToken.self, forKey: .paginationToken)
  }
}

let accountGeofenceDeviceID: NonEmptyString = "00000000-0000-0000-0000-000000000000"

extension Geofence: Decodable {
  enum CodingKeys: String, CodingKey {
    case id = "geofence_id"
    case deviceID = "device_id"
    case address
    case createdAt = "created_at"
    case geometry
    case metadata
    case radius
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    id = try values.decode(NonEmptyString.self, forKey: .id)
    
    deviceID = (try? values.decode(NonEmptyString.self, forKey: .deviceID)) ?? accountGeofenceDeviceID
    
    address = (try? values.decodeIfPresent(String.self, forKey: .address)) ?? ""
    
    createdAt = try decodeTimestamp(decoder: decoder, container: values, key: .createdAt)
    let radius = try? values.decodeIfPresent(UInt.self, forKey: .radius)
    shape = try decodeGeofenceShape(radius: radius, decoder: decoder, container: values, key: .geometry)
    metadata = try decodeMetadata(decoder: decoder, container: values, key: .metadata)

    markers = []
  }
}

extension VisitStatus {
  var entered: Date {
    switch self {
    case let .entered(entered), let .visited(entered, _): return entered
    }
  }
}

struct GeofenceMarker {
  let id: NonEmptyString
  let geofenceID: NonEmptyString
  let visitStatus: VisitStatus
  let routeTo: RouteTo?
}

struct RouteTo {
  let distance: UInt
  let duration: UInt
}

extension RouteTo: Decodable {
  enum CodingKeys: String, CodingKey {
    case distance
    case duration
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    distance = try values.decode(UInt.self, forKey: .distance)
    duration = try values.decode(UInt.self, forKey: .duration)
  }
}

extension GeofenceMarker: Decodable {
  enum CodingKeys: String, CodingKey {
    case id
    case geofence
    case arrival
    case exit
    case routeTo = "route_to"
  }

  enum GeofenceCodingKeys: String, CodingKey {
    case geofenceID = "geofence_id"
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    id = try values.decode(NonEmptyString.self, forKey: .id)

    guard id.rawValue.rangeOfCharacter(from: .whitespacesAndNewlines) == nil else {
      throw DecodingError.dataCorrupted(
        .init(
          codingPath: decoder.codingPath,
          debugDescription: #"Geofence ID can't contain whitespaces or new lines. Received ID: "\#(id.rawValue)""#
        )
      )
    }

    let geofence = try values.nestedContainer(keyedBy: GeofenceCodingKeys.self, forKey: .geofence)
    geofenceID = try geofence.decode(NonEmptyString.self, forKey: .geofenceID)

    let arrival = try values.decode(Crossing.self, forKey: .arrival)
    let exit = try? values.decodeIfPresent(Crossing.self, forKey: .exit)
    
    switch exit {
    case let .some(exit):
      visitStatus = .visited(arrival.recordedAt, exit.recordedAt)
    case .none:
      visitStatus = .entered(arrival.recordedAt)
    }
    
    routeTo = try values.decode(RouteTo?.self, forKey: .routeTo)
  }
}

struct Crossing {
  let recordedAt: Date
}

extension Crossing: Decodable {
  enum CodingKeys: String, CodingKey {
    case recordedAt = "recorded_at"
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    recordedAt = try decodeTimestamp(decoder: decoder, container: values, key: .recordedAt)
  }
}
