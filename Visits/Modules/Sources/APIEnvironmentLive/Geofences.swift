import APIEnvironment
import Combine
import Foundation
import NonEmpty
import Types


func getGeofences(auth token: Token, deviceID: DeviceID) -> AnyPublisher<[Geofence], APIError> {
  paginate(
    getPage: { pagination in
      getGeofencesPage(auth: token, deviceID: deviceID, paginationToken: pagination)
    },
    valuesFromPage: \.geofences,
    paginationFromPage: \.paginationToken
  )
}

func getGeofencesPage(auth token: Token, deviceID: DeviceID, paginationToken: PaginationToken?) -> AnyPublisher<GeofencePage, APIError> {
  URLSession.shared.dataTaskPublisher(for: geofencesRequest(auth: token, deviceID: deviceID, paginationToken: paginationToken))
    .map(\.data)
    .decode(type: GeofencePage.self, decoder: JSONDecoder())
    .mapError { _ in .unknown }
    .eraseToAnyPublisher()
}

func geofencesRequest(auth token: Token, deviceID: DeviceID, paginationToken: PaginationToken?) -> URLRequest {
  var components = URLComponents()
  components.scheme = "https"
  components.host = "live-app-backend.htprod.hypertrack.com"
  components.path = "/client/geofences"
  components.queryItems = [
    URLQueryItem(name: "device_id", value: deviceID.rawValue.rawValue),
    URLQueryItem(name: "include_archived", value: "false"),
    URLQueryItem(name: "include_markers", value: "true")
  ]
  if let paginationToken = paginationToken, let queryItems = components.queryItems {
    components.queryItems = queryItems + [
      URLQueryItem(name: "pagination_token", value: paginationToken.rawValue.rawValue)
    ]
  }
  
  var request = URLRequest(url: components.url!)
  request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
  request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
  request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
  request.httpMethod = "GET"
  return request
}

struct GeofencePage {
  let geofences: [Geofence]
  let paginationToken: PaginationToken?
}


struct Geofence {
  let id: NonEmptyString
  let createdAt: Date
  let coordinate: Coordinate
  let metadata: NonEmptyDictionary<NonEmptyString, NonEmptyString>?
  let visitStatus: VisitStatus?
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

extension Geofence: Decodable {
  enum CodingKeys: String, CodingKey {
    case id = "geofence_id"
    case createdAt = "created_at"
    case geometry
    case metadata
    case markers
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    id = try values.decode(NonEmptyString.self, forKey: .id)
    createdAt = try decodeTimestamp(decoder: decoder, container: values, key: .createdAt)
    coordinate = try decodeGeofenceCentroid(decoder: decoder, container: values, key: .geometry)
    metadata = try decodeMetadata(decoder: decoder, container: values, key: .metadata)
    
    let geofenceMarkers = try? values.decodeIfPresent(GeofenceMarkerContainer.self, forKey: .markers)
    switch geofenceMarkers {
    case let .some(markerContainer):
      visitStatus = visitStatusFrom(geofenceMarkers: markerContainer.data)
    case .none:
      visitStatus = nil
    }
  }
}

extension Sequence {
  func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
    return sorted { a, b in
      return a[keyPath: keyPath] < b[keyPath: keyPath]
    }
  }
}

func visitStatusFrom(geofenceMarkers: [GeofenceMarker]) -> VisitStatus? {
  let geofenceMarkers = geofenceMarkers.sorted(by: \.createdAt)
  
  guard let first = geofenceMarkers.first else { return nil }
  
  if let last = geofenceMarkers.last, geofenceMarkers.count != 1 {
    switch last.visitStatus {
    case .entered:
      return .entered(first.visitStatus.entered)
    case let .visited(_, exited):
      return .visited(first.visitStatus.entered, exited)
    }
  } else {
    return first.visitStatus
  }
}

extension VisitStatus {
  var entered: Date {
    switch self {
    case let .entered(entered), let .visited(entered, _): return entered
    }
  }
}

struct GeofenceMarkerContainer {
  let data: [GeofenceMarker]
}

extension GeofenceMarkerContainer: Decodable {
  enum CodingKeys: String, CodingKey {
    case data
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    data = try values.decode([GeofenceMarker].self, forKey: .data)
  }
}

struct GeofenceMarker {
  let createdAt: Date
  let visitStatus: VisitStatus
}

extension GeofenceMarker: Decodable {
  enum CodingKeys: String, CodingKey {
    case createdAt = "created_at"
    case arrival
    case exit
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    createdAt = try decodeTimestamp(decoder: decoder, container: values, key: .createdAt)
    
    let arrival = try values.decode(Crossing.self, forKey: .arrival)
    let exit = try? values.decodeIfPresent(Crossing.self, forKey: .exit)
    
    switch exit {
    case let .some(exit):
      visitStatus = .visited(arrival.recordedAt, exit.recordedAt)
    case .none:
      visitStatus = .entered(arrival.recordedAt)
    }
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
