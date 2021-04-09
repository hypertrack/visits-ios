import APIEnvironment
import Combine
import ComposableArchitecture
import Foundation
import LogEnvironment
import NonEmpty
import Prelude
import Tagged
import Types


func getPlaces(_ pk: PublishableKey, _ deID: DeviceID) -> Effect<Result<Set<Place>, APIError>, Never> {
  logEffect("getPlaces", failureType: APIError.self)
    .flatMap { getToken(auth: pk, deviceID: deID) }
    .flatMap { t in
      getGeofences(auth: t, deviceID: deID)
        .map { Set($0.compactMap(Place.init(geofence:))) }
    }
    .map(Result.success)
    .catch(Result.failure >>> Just.init(_:))
    .eraseToEffect()
}

func getGeofences(auth token: Token, deviceID: DeviceID) -> AnyPublisher<[Geofence], APIError> {
  paginate(
    getPage: { pagination in
      getGeofencesPage(auth: token, deviceID: deviceID, paginationToken: pagination)
    },
    valuesFromPage: \.geofences,
    paginationFromPage: \.paginationToken
  )
  
  .eraseToAnyPublisher()
}

func getGeofencesPage(auth token: Token, deviceID: DeviceID, paginationToken: PaginationToken?) -> AnyPublisher<GeofencePage, APIError> {
  URLSession.shared.dataTaskPublisher(for: geofencesRequest(auth: token, deviceID: deviceID, paginationToken: paginationToken))
    .map(\.data)
    .decode(type: GeofencePage.self, decoder: JSONDecoder())
    .mapError { error in
      print(error)
      return .unknown
    }
    .eraseToAnyPublisher()
}

func geofencesRequest(auth token: Token, deviceID: DeviceID, paginationToken: PaginationToken?) -> URLRequest {
  var components = URLComponents()
  components.scheme = "https"
  components.host = "live-app-backend.htprod.hypertrack.com"
  components.path = "/client/geofences"
  components.queryItems = [
    URLQueryItem(name: "device_id", value: "\(deviceID)"),
    URLQueryItem(name: "include_archived", value: "false"),
    URLQueryItem(name: "include_markers", value: "true")
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

extension Place {
  init?(geofence: Geofence) {
    let id: Place.ID = wrap(geofence.id)
    let address: Address = .init(string: geofence.address)
    let createdAt: Place.CreatedTimestamp = wrap(geofence.createdAt)
    let metadata: [Place.Name : Place.Contents] = geofence.metadata.map(\.rawValue).map(wrapDictionary) ?? [:]
    let shape = geofence.shape
       
    func wrapRoute(_ routeTo: RouteTo) -> Place.Route {
      .init(
        distance: wrap(routeTo.distance),
        duration: wrap(routeTo.duration),
        idleTime: wrap(routeTo.idleTime)
      )
    }
    
    let visitOrExit: [Either<Place.Visit, Place.Entry>] = geofence.markers.map { marker in
      switch marker.visitStatus {
      case let .entered(en):
        return .right(
          .init(
            entry: wrap(en),
            duration: wrap(marker.duration),
            route: marker.routeTo.map(wrapRoute)
          )
        )
      case let .visited(en, ex):
        return .left(
          .init(
            entry: wrap(en),
            exit: wrap(ex),
            duration: wrap(marker.duration),
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
  let address: String
  let createdAt: Date
  let metadata: NonEmptyDictionary<NonEmptyString, NonEmptyString>?
  let shape: GeofenceShape
  let markers: [GeofenceMarker]
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
    case address
    case createdAt = "created_at"
    case geometry
    case metadata
    case markers
    case radius
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    id = try values.decode(NonEmptyString.self, forKey: .id)
    
    address = (try? values.decodeIfPresent(String.self, forKey: .address)) ?? ""
    
    createdAt = try decodeTimestamp(decoder: decoder, container: values, key: .createdAt)
    let radius = try? values.decodeIfPresent(UInt.self, forKey: .radius)
    shape = try decodeGeofenceShape(radius: radius, decoder: decoder, container: values, key: .geometry)
    metadata = try decodeMetadata(decoder: decoder, container: values, key: .metadata)
    
    let geofenceMarkers = try? values.decode(GeofenceMarkerContainer.self, forKey: .markers)
    markers = geofenceMarkers?.data ?? []
  }
}

extension Sequence {
  func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
    return sorted { a, b in
      return a[keyPath: keyPath] < b[keyPath: keyPath]
    }
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
  let routeTo: RouteTo?
  let duration: UInt
}

struct RouteTo {
  let distance: UInt
  let duration: UInt
  let idleTime: UInt
}

extension RouteTo: Decodable {
  enum CodingKeys: String, CodingKey {
    case distance
    case duration
    case idleTime = "idle_time"
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    distance = try values.decode(UInt.self, forKey: .distance)
    duration = try values.decode(UInt.self, forKey: .duration)
    idleTime = try values.decode(UInt.self, forKey: .idleTime)
  }
}

extension GeofenceMarker: Decodable {
  enum CodingKeys: String, CodingKey {
    case createdAt = "created_at"
    case arrival
    case duration
    case exit
    case routeTo = "route_to"
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
    
    routeTo = try values.decode(RouteTo?.self, forKey: .routeTo)
    
    duration = (try? values.decode(UInt.self, forKey: .duration)) ?? 0
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
