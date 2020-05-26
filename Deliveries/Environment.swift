import Foundation
import ComposableArchitecture
import Prelude
import Combine
import MapKit
import Contacts
import GLKit

public enum GeofenceType: String {
  case point = "Point"
  case polygon = "Polygon"
}

public typealias DeliveriesListOrErrorString = Either<[DeliveryModel], NonEmptyString>

public func getDeliveries(_ publishableKey: NonEmptyString, _ deviceID: NonEmptyString) -> Effect<DeliveriesListOrErrorString, Never> {
  return getTokenFuture(auth: publishableKey, deviceID: deviceID)
    .flatMap { deliveriesFuture(auth: $0, deviceID: deviceID) }
    .map { DeliveriesListOrErrorString.left($0) }
    .catch { Just(DeliveriesListOrErrorString.right($0)) }
    .eraseToEffect()
}

extension NonEmptyString: Error {}

// MARK: - Delivery model

public struct DeliveryModel: Identifiable {
  public let id: NonEmptyString
  public let createdAt: Date
  public let lat: Double
  public let lng: Double
  public var shortAddress: String = ""
  public var fullAddress: String = ""
  public let metadata: [Metadata]
   
  public struct Metadata: Hashable {
    public let key: String
    public let value: String
    
    public init(key: String, value: String) {
      self.key = key
      self.value = value
    }
  }
  
  public init(
    id: NonEmptyString,
    createdAt: Date,
    lat: Double,
    lng: Double,
    shortAddress: String = "",
    fullAddress: String = "",
    metadata: [DeliveryModel.Metadata]
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

extension DeliveryModel: Equatable {
  public static func == (lhs: DeliveryModel, rhs: DeliveryModel) -> Bool {
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

func decodeDeliveryArrayData(data: Data) -> AnyPublisher<[DeliveryModel], Error> {
  Future<[DeliveryModel], Error> { promise in
    do {
      let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
     
      guard let deliveriesjson = json else {
        promise(.failure(NonEmptyString("Can't parse deliveries response")))
        return
      }
      
      var decodedDelivery: [DeliveryModel] = []
     
      for jsonItem in deliveriesjson {
        
        if let model = createDeliveryFrom(json: jsonItem) {
          
          decodedDelivery.append(model)
          
        }
        
      }
        
      promise(.success(decodedDelivery))
    } catch let error {
      promise(.failure(error))
    }
  }
  .eraseToAnyPublisher()
}

func createDeliveryFrom(json: [String: Any]) -> DeliveryModel? {
  let id = json[GeofenceKeys.id.rawValue] as? String
  let geometry = json[GeofenceKeys.geometry.rawValue] as? [String: Any]
  let type = geometry?[GeofenceKeys.type.rawValue] as? String
  let createdAtString = json[GeofenceKeys.createdAt.rawValue] as? String
  var metadataList: [DeliveryModel.Metadata] = []
  let metadataJson = json[GeofenceKeys.metadata.rawValue] as? [String: Any]
  
  if let unwrappedMetadata = metadataJson {
    for keyValue in unwrappedMetadata {
     
      let value = keyValue.value as? String
     
      if let metaValue = value {
        metadataList.append(DeliveryModel.Metadata(key: keyValue.key, value: metaValue))
      }
    }
  }
  
  if let deliveryID = id, let deliveryType = type, let date = createdAtString?.iso8601 {
    switch deliveryType {
    case GeofenceType.point.rawValue:
      
      let pointCoordinate = geometry?[GeofenceKeys.coordinates.rawValue] as? [Double]
      let lng = pointCoordinate?.first
      let lat = pointCoordinate?.last
      
      if let latitude = lat, let longitude = lng {
        return DeliveryModel(id: NonEmptyString(stringLiteral: deliveryID), createdAt: date, lat: latitude, lng: longitude, metadata: metadataList)
      } else {
        return nil
      }
    case GeofenceType.polygon.rawValue:
      
      let polygonCoordinate = geometry?[GeofenceKeys.coordinates.rawValue] as? [[Double]]
      
      if let coordinate = polygonCoordinate, coordinate.count > 2 {
        
        let points = coordinate.map { CLLocationCoordinate2D(latitude: $0.last!, longitude: $0.first!) }
        
        let centroidCoordinate = getPolygonCentroid(points)
        
        return DeliveryModel(id: NonEmptyString(stringLiteral: deliveryID), createdAt: date, lat: centroidCoordinate.latitude, lng: centroidCoordinate.longitude, metadata: metadataList)
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

func sortDeliveries(deliveries: [DeliveryModel]) -> AnyPublisher<[DeliveryModel], Error> {
  Future<[DeliveryModel], Error> { promise in
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

// MARK: - AuthenticateResponse model

public struct AuthenticateResponse: Decodable {
  public let tokenType: String
  public let expiresIn: Int
  public let accessToken: String
  
  enum Keys: String, CodingKey {
    case tokenType = "token_type"
    case expiresIn = "expires_in"
    case accessToken = "access_token"
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: Keys.self)
    tokenType = try container.decode(String.self, forKey: .tokenType)
    expiresIn = try container.decode(Int.self, forKey: .expiresIn)
    accessToken = try container.decode(String.self, forKey: .accessToken)
  }
}

// MARK: - Pipeline

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
  .mapError { NonEmptyString(rawValue: $0.localizedDescription)! }
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

func deliveriesFuture(auth token: NonEmptyString, deviceID: NonEmptyString) -> AnyPublisher<[DeliveryModel], NonEmptyString> {
  URLSession.shared.dataTaskPublisher(for: deliveriesRequest(auth: token, deviceID: deviceID))
  .map { data, _ in data }
  .mapError { $0 as Error }
  .flatMap { decodeDeliveryArrayData(data: $0) }
  .flatMap { geocodingFor(deliveries: $0) }
  .flatMap { sortDeliveries(deliveries: $0) }
  .mapError { NonEmptyString(rawValue: $0.localizedDescription)! }
  .eraseToAnyPublisher()
}

public func deliveriesDismissTimer(scheduler: AnySchedulerOf<DispatchQueue>) -> Effect<Void, Never> {
  Just(())
    .delay(for: .seconds(20), scheduler: scheduler)
    .eraseToEffect()
}

func geocodingFor(deliveries: [DeliveryModel]) -> AnyPublisher<[DeliveryModel], Error> {
  Publishers.Sequence(sequence: deliveries)
    .flatMap { geocodingSingleSequence(delivery: $0) }
    .collect()
    .eraseToAnyPublisher()
}

func geocodingSingleSequence(delivery: DeliveryModel) -> AnyPublisher<DeliveryModel, Error> {
  Future<DeliveryModel, Error> { promise in
    makeSearchGeocode(model: delivery) {
      if let model = $0 {
        promise(.success(model))
      } else {
        promise(.success(delivery))
      }
    }
  }
  .eraseToAnyPublisher()
}

private func makeSearchGeocode(model: DeliveryModel, completion: @escaping (DeliveryModel?) -> Void) {
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
      insideModel = insideModel |> \.shortAddress .~ placemarksName
    } else {
      insideModel = insideModel |> \.shortAddress .~ formattedAddress
    }
    
    insideModel = insideModel |> \.fullAddress .~ formattedAddress
    
    print("insideModel fullAddress: \(insideModel.fullAddress)")
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

let failedToGetRestToken = { NonEmptyString(rawValue: "Failed to get rest token with error: " + $0)! }
let failedToDownloadDeliveries = { NonEmptyString(rawValue: "Failed to download deliveries with error: " + $0)! }
