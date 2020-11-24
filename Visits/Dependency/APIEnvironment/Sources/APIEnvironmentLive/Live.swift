import APIEnvironment
import Combine
import ComposableArchitecture
import Contacts
import Coordinate
import CoreLocation
import DeviceID
import GLKit
import History
import MapKit
import NonEmpty
import Prelude
import PublishableKey
import Visit

// MARK: - Get History

public func getHistory(_ pk: PublishableKey, _ dID: DeviceID, _ date: Date) -> Effect<Either<History, NonEmptyString>, Never> {
  getTokenFuture(auth: pk.rawValue, deviceID: dID.rawValue)
    .flatMap { historyFuture(auth: $0, deviceID: dID.rawValue, date: date) }
    .map { .left($0) }
    .catch { Just(.right($0)) }
    .eraseToEffect()
}

extension History: Decodable {
  enum CodingKeys: String, CodingKey {
    case distance
    case locations
  }
  
  enum LocationsCodingKeys: String, CodingKey {
    case coordinates
  }
  
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    let distance = try values.decode(UInt.self, forKey: .distance)
    let locationsJSON = try values.nestedContainer(keyedBy: LocationsCodingKeys.self, forKey: .locations)
    var coordinatesJSON = try locationsJSON.nestedUnkeyedContainer(forKey: .coordinates)
    var coordinatesM: [Coordinate] = []
    while !coordinatesJSON.isAtEnd {
      var nestedCoordinatesJSON = try coordinatesJSON.nestedUnkeyedContainer()
      if let count = nestedCoordinatesJSON.count, count >= 2 {
        let longitude = try nestedCoordinatesJSON.decode(Double.self)
        let latitude = try nestedCoordinatesJSON.decode(Double.self)
        if let coordinate = Coordinate(latitude: latitude, longitude: longitude) {
          coordinatesM.append(coordinate)
        }
      }
    }
    let coordinates = coordinatesM
    self.init(coordinates: coordinates, distance: distance)
  }
}

func historyFuture(auth token: NonEmptyString, deviceID: NonEmptyString, date: Date) -> AnyPublisher<History, NonEmptyString> {
  URLSession.shared.dataTaskPublisher(for: historyRequest(auth: token, deviceID: deviceID, date: date))
    .map { data, _ in data }
    .decode(type: History.self, decoder: JSONDecoder())
    .mapError { NonEmptyString(rawValue: $0.localizedDescription) ?? NonEmptyString(stringLiteral: "Unknown error") }
    .eraseToAnyPublisher()
}

func historyRequest(auth token: NonEmptyString, deviceID: NonEmptyString, date: Date) -> URLRequest {
  let url = URL(string: "https://live-app-backend.htprod.hypertrack.com/client/devices/\(deviceID.rawValue)/history/\(historyDate(from: date))")!
  var request = URLRequest(url: url)
  request.setValue("Bearer \(token.rawValue)", forHTTPHeaderField: "Authorization")
  request.httpMethod = "GET"
  return request
}

func historyDate(from date: Date) -> String {
  let formatter = DateFormatter()
  formatter.dateFormat = "yyyy-MM-dd"
  return formatter.string(from: date)
}

// MARK: - Get Visits

public func getVisits(_ pk: PublishableKey, _ dID: DeviceID) -> Effect<Either<NonEmptySet<AssignedVisit>, NonEmptyString>, Never> {
  getDeliveries(pk.rawValue, dID.rawValue)
    .map { visitOrError in
      switch visitOrError {
      case let .left(ds):
        let aas = ds.compactMap { d -> AssignedVisit? in
          let address: These<AssignedVisit.Street, AssignedVisit.FullAddress>?
          switch (NonEmptyString(rawValue: d.shortAddress), NonEmptyString(rawValue: d.fullAddress)) {
          case let (.some(street), .some(full)):
            address = .both(AssignedVisit.Street(rawValue: street), AssignedVisit.FullAddress(rawValue: full))
          case let (.some(street), .none):
            address = .this(AssignedVisit.Street(rawValue: street))
          case let (.none, .some(full)):
            address = .that(AssignedVisit.FullAddress(rawValue: full))
          case (.none, .none):
            address = nil
          }
          let metadata = NonEmptyDictionary(
            rawValue: d.metadata.compactMap { metadata -> (AssignedVisit.Name, AssignedVisit.Contents)? in
              if let nonemptyName = NonEmptyString(rawValue: metadata.key),
                 let nonemptyContents = NonEmptyString(rawValue: metadata.value) {
                return (AssignedVisit.Name(rawValue: nonemptyName), AssignedVisit.Contents(rawValue: nonemptyContents))
              }
              return nil
            }.reduce(into: Dictionary<AssignedVisit.Name, AssignedVisit.Contents>()) { (dict, tuple) in
              dict.updateValue(tuple.1, forKey: tuple.0)
            }
          )
          if let coordinate = Coordinate(latitude: d.lat, longitude: d.lng) {
            return AssignedVisit(
              id: .init(rawValue: d.id),
              createdAt: d.createdAt,
              source: .geofence,
              location: coordinate,
              geotagSent: .notSent,
              noteFieldFocused: false,
              address: address,
              visitNote: nil,
              metadata: metadata
            )
          }
          return nil
        }
        if let nons = NonEmptySet(rawValue: Set(aas)) {
          return .left(nons)
        } else {
          return .right("No results")
        }
      case let .right(e):
        return .right(e)
      }
    }
}

enum GeofenceType: String {
  case point = "Point"
  case polygon = "Polygon"
}

typealias DeliveriesListOrErrorString = Either<[VisitModel], NonEmptyString>

func getDeliveries(_ publishableKey: NonEmptyString, _ deviceID: NonEmptyString) -> Effect<DeliveriesListOrErrorString, Never> {
  getTokenFuture(auth: publishableKey, deviceID: deviceID)
    .flatMap { deliveriesFuture(auth: $0, deviceID: deviceID) }
    .map { DeliveriesListOrErrorString.left($0) }
    .catch { Just(DeliveriesListOrErrorString.right($0)) }
    .eraseToEffect()
}

extension NonEmptyString: Error {}

// MARK: Visit model

struct VisitModel: Identifiable {
  let id: NonEmptyString
  let createdAt: Date
  let lat: Double
  let lng: Double
  var shortAddress: String = ""
  var fullAddress: String = ""
  let metadata: [Metadata]
  
  struct Metadata: Hashable {
    let key: String
    let value: String
    
    init(key: String, value: String) {
      self.key = key
      self.value = value
    }
  }
  
  init(
    id: NonEmptyString,
    createdAt: Date,
    lat: Double,
    lng: Double,
    shortAddress: String = "",
    fullAddress: String = "",
    metadata: [VisitModel.Metadata]
  ) {
    self.id = id
    self.createdAt = createdAt
    self.lat = lat
    self.lng = lng
    self.shortAddress = shortAddress
    self.fullAddress = fullAddress
    self.metadata = metadata
  }
}

extension VisitModel: Equatable {
  static func == (lhs: VisitModel, rhs: VisitModel) -> Bool {
    return lhs.id == rhs.id
  }
}

private enum GeofenceKeys: String {
  case id = "geofence_id"
  case geometry = "geometry"
  case type = "type"
  case coordinates = "coordinates"
  case metadata = "metadata"
  case createdAt = "created_at"
}

func decodeVisitArrayData(data: Data) -> AnyPublisher<[VisitModel], Error> {
  Future<[VisitModel], Error> { promise in
    do {
      let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
      
      guard let deliveriesjson = json else {
        promise(.failure(NonEmptyString("Can't parse deliveries response")))
        return
      }
      
      var decodedVisit: [VisitModel] = []
      
      for jsonItem in deliveriesjson {
        
        if let model = createVisitFrom(json: jsonItem) {
          
          decodedVisit.append(model)
          
        }
        
      }
      
      promise(.success(decodedVisit))
    } catch let error {
      promise(.failure(error))
    }
  }
  .eraseToAnyPublisher()
}

func createVisitFrom(json: [String: Any]) -> VisitModel? {
  let id = json[GeofenceKeys.id.rawValue] as? String
  let geometry = json[GeofenceKeys.geometry.rawValue] as? [String: Any]
  let type = geometry?[GeofenceKeys.type.rawValue] as? String
  let createdAtString = json[GeofenceKeys.createdAt.rawValue] as? String
  var metadataList: [VisitModel.Metadata] = []
  let metadataJson = json[GeofenceKeys.metadata.rawValue] as? [String: Any]
  
  if let unwrappedMetadata = metadataJson {
    for keyValue in unwrappedMetadata {
      
      let value = keyValue.value as? String
      
      if let metaValue = value {
        metadataList.append(VisitModel.Metadata(key: keyValue.key, value: metaValue))
      }
    }
  }
  
  if let visitID = id, let visitType = type, let date = createdAtString?.iso8601 {
    switch visitType {
    case GeofenceType.point.rawValue:
      
      let pointCoordinate = geometry?[GeofenceKeys.coordinates.rawValue] as? [Double]
      let lng = pointCoordinate?.first
      let lat = pointCoordinate?.last
      
      if let latitude = lat, let longitude = lng {
        return VisitModel(id: NonEmptyString(stringLiteral: visitID), createdAt: date, lat: latitude, lng: longitude, metadata: metadataList)
      } else {
        return nil
      }
    case GeofenceType.polygon.rawValue:
      
      let polygonCoordinate = geometry?[GeofenceKeys.coordinates.rawValue] as? [[Double]]
      
      if let coordinate = polygonCoordinate, coordinate.count > 2 {
        
        let points = coordinate.map { CLLocationCoordinate2D(latitude: $0.last!, longitude: $0.first!) }
        
        let centroidCoordinate = getPolygonCentroid(points)
        
        return VisitModel(id: NonEmptyString(stringLiteral: visitID), createdAt: date, lat: centroidCoordinate.latitude, lng: centroidCoordinate.longitude, metadata: metadataList)
      } else {
        return nil
      }
    default:
      return nil
    }
  } else {
    return nil
  }
}

func getPolygonCentroid(_ points: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D {
  var x:Float = 0.0
  var y:Float = 0.0
  var z:Float = 0.0
  for points in points {
    let lat = GLKMathDegreesToRadians(Float(points.latitude))
    let long = GLKMathDegreesToRadians(Float(points.longitude))
    
    x += cos(lat) * cos(long)
    
    y += cos(lat) * sin(long)
    
    z += sin(lat)
  }
  x = x / Float(points.count)
  y = y / Float(points.count)
  z = z / Float(points.count)
  let resultLong = atan2(y, x)
  let resultHyp = sqrt(x * x + y * y)
  let resultLat = atan2(z, resultHyp)
  let result = CLLocationCoordinate2D(latitude: CLLocationDegrees(GLKMathRadiansToDegrees(Float(resultLat))), longitude: CLLocationDegrees(GLKMathRadiansToDegrees(Float(resultLong))))
  return result
}

func sortDeliveries(deliveries: [VisitModel]) -> AnyPublisher<[VisitModel], Error> {
  Future<[VisitModel], Error> { promise in
    var sortedDeliveries = deliveries
    sortedDeliveries = sortedDeliveries.sorted {
      if $0.createdAt == $1.createdAt {
        return $0.id.rawValue < $1.id.rawValue
      } else {
        return $0.createdAt.timeIntervalSinceReferenceDate < $1.createdAt.timeIntervalSinceReferenceDate
      }
    }
    promise(.success(sortedDeliveries))
  }
  .eraseToAnyPublisher()
}

// MARK: AuthenticateResponse model

struct AuthenticateResponse: Decodable {
  let tokenType: String
  let expiresIn: Int
  let accessToken: String
  
  enum Keys: String, CodingKey {
    case tokenType = "token_type"
    case expiresIn = "expires_in"
    case accessToken = "access_token"
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: Keys.self)
    tokenType = try container.decode(String.self, forKey: .tokenType)
    expiresIn = try container.decode(Int.self, forKey: .expiresIn)
    accessToken = try container.decode(String.self, forKey: .accessToken)
  }
}

// MARK: Pipeline

func authorizationRequest(auth publishableKey: NonEmptyString, deviceID: NonEmptyString) -> URLRequest {
  let url = URL(string: "https://live-api.htprod.hypertrack.com/authenticate")!
  var request = URLRequest(url: url)
  request.setValue("Basic \(Data(publishableKey.rawValue.utf8).base64EncodedString(options: []))", forHTTPHeaderField: "Authorization")
  request.httpBody = try! JSONSerialization.data(withJSONObject: ["device_id" : deviceID.rawValue], options: JSONSerialization.WritingOptions(rawValue: 0))
  request.httpMethod = "POST"
  return request
}

func getTokenFuture(auth publishableKey: NonEmptyString, deviceID: NonEmptyString) -> AnyPublisher<NonEmptyString, NonEmptyString> {
  URLSession.shared.dataTaskPublisher(for: authorizationRequest(auth: publishableKey, deviceID: deviceID))
    .map { data, _ in data }
    .decode(type: AuthenticateResponse.self, decoder: JSONDecoder())
    .mapError { NonEmptyString(rawValue: $0.localizedDescription) ?? NonEmptyString(stringLiteral: "Unknown error") }
    .tryMap { token in
      if let token = NonEmptyString(rawValue: token.accessToken) {
        return token
      } else {
        throw failedToGetRestToken("VFSEQ0")
      }
    }
    .mapError { $0 as! NonEmptyString }
    .eraseToAnyPublisher()
}

func deliveriesRequest(auth token: NonEmptyString, deviceID: NonEmptyString) -> URLRequest {
  let url = URL(string: "https://live-app-backend.htprod.hypertrack.com/client/devices/\(deviceID.rawValue)/geofences")!
  var request = URLRequest(url: url)
  request.setValue("Bearer \(token.rawValue)", forHTTPHeaderField: "Authorization")
  request.httpMethod = "GET"
  return request
}

func deliveriesFuture(auth token: NonEmptyString, deviceID: NonEmptyString) -> AnyPublisher<[VisitModel], NonEmptyString> {
  URLSession.shared.dataTaskPublisher(for: deliveriesRequest(auth: token, deviceID: deviceID))
    .map { data, _ in data }
    .mapError { $0 as Error }
    .flatMap { decodeVisitArrayData(data: $0) }
    .flatMap { geocodingFor(deliveries: $0) }
    .flatMap { sortDeliveries(deliveries: $0) }
    .mapError { NonEmptyString(rawValue: $0.localizedDescription) ?? NonEmptyString(stringLiteral: "Unknown error") }
    .eraseToAnyPublisher()
}

func deliveriesDismissTimer(scheduler: AnySchedulerOf<DispatchQueue>) -> Effect<Void, Never> {
  Just(())
    .delay(for: .seconds(20), scheduler: scheduler)
    .eraseToEffect()
}

func geocodingFor(deliveries: [VisitModel]) -> AnyPublisher<[VisitModel], Error> {
  Publishers.Sequence(sequence: deliveries)
    .flatMap { geocodingSingleSequence(visit: $0) }
    .collect()
    .eraseToAnyPublisher()
}

func geocodingSingleSequence(visit: VisitModel) -> AnyPublisher<VisitModel, Error> {
  Future<VisitModel, Error> { promise in
    makeSearchGeocode(model: visit) {
      if let model = $0 {
        promise(.success(model))
      } else {
        promise(.success(visit))
      }
    }
  }
  .eraseToAnyPublisher()
}

private func makeSearchGeocode(model: VisitModel, completion: @escaping (VisitModel?) -> Void) {
  var insideModel = model
  CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: model.lat, longitude: model.lng), completionHandler: { (placemarks, error) -> Void in
    guard error == nil else {
      print("Received error on address serch result: \(String(describing: error)) | \(String(describing: error?.localizedDescription))")
      completion(nil)
      return
    }
    guard let first = placemarks?.first else { completion(nil); return }
    
    let thoroughfare = first.thoroughfare ?? ""
    let subThoroughfare = first.subThoroughfare ?? ""
    
    let placemarksName = "\(thoroughfare) \(subThoroughfare)"
    let formattedAddress = first.formattedAddress ?? ""
    
    if placemarksName.clean().count > 0 {
      insideModel.shortAddress = placemarksName
    } else {
      insideModel.shortAddress = formattedAddress
    }
    
    insideModel.fullAddress = formattedAddress
    
    completion(insideModel)
  })
}

extension CLPlacemark {
  var formattedAddress: String? {
    guard let postalAddress = postalAddress else { return nil }
    return CNPostalAddressFormatter.string(
      from: postalAddress,
      style: .mailingAddress
    ).replacingOccurrences(of: "\n", with: " ")
  }
}

let failedToGetRestToken = { NonEmptyString(stringLiteral: "Failed to get rest token with error: " + $0) }
let failedToDownloadDeliveries = { NonEmptyString(stringLiteral: "Failed to download deliveries with error: " + $0) }
