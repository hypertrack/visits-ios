import APIEnvironment
import Combine
import ComposableArchitecture
import Contacts
import Coordinate
import CoreLocation
import Credentials
import DeviceID
import GeoJSON
import GLKit
import History
import Log
import MapKit
import NonEmpty
import Prelude
import PublishableKey
import Tagged
import Visit


public extension APIEnvironment {
  static let live = Self(
    getHistory: getHistory(_:_:_:),
    getVisits: getVisits(_:_:),
    reverseGeocode: reverseGeocode(_:),
    signIn: signIn(_:_:)
  )
}

let baseURL: NonEmptyString = "https://live-app-backend.htprod.hypertrack.com"
let clientURL: NonEmptyString = baseURL + "/client"
let internalAPIURL: NonEmptyString = "https://live-api.htprod.hypertrack.com"

extension NonEmptyString: Error {}

// MARK: - Sign In

func signIn(_ email: Email, _ password: Password) -> Effect<Either<PublishableKey, NonEmptyString>, Never> {
  URLSession.shared.dataTaskPublisher(for: signInRequest(email: email, password: password))
    .map { data, _ in data }
    .decode(type: SignIn.self, decoder: JSONDecoder())
    .map(\.publishableKey >>> Either.left)
    .mapError { NonEmptyString(rawValue: $0.localizedDescription) ?? NonEmptyString(stringLiteral: "Unknown error") }
    .catch(Either.right >>> Just.init(_:))
    .eraseToEffect()
}

struct SignIn: Decodable {
  enum CodingKeys: String, CodingKey {
    case publishableKey = "publishable_key"
  }
  
  let publishableKey: PublishableKey
}

func signInRequest(email: Email, password: Password) -> URLRequest {
  let url = URL(string: baseURL.rawValue + "/get_publishable_key")!
  var request = URLRequest(url: url)
  request.httpBody = try! JSONSerialization.data(
    withJSONObject: [
      "username": email.rawValue.rawValue,
      "password": password.rawValue.rawValue
    ],
    options: JSONSerialization.WritingOptions(rawValue: 0)
  )
  request.httpMethod = "POST"
  return request
}

// MARK: - Get Token

typealias Token = Tagged<TokenTag, NonEmptyString>
enum TokenTag {}

func getToken(auth publishableKey: PublishableKey, deviceID: DeviceID) -> AnyPublisher<Token, NonEmptyString> {
  URLSession.shared.dataTaskPublisher(for: authorizationRequest(auth: publishableKey, deviceID: deviceID))
    .map { data, _ in data }
    .decode(type: Authentication.self, decoder: JSONDecoder())
    .map(\.accessToken)
    .mapError { NonEmptyString(rawValue: $0.localizedDescription) ?? NonEmptyString(stringLiteral: "Unknown error") }
    .eraseToAnyPublisher()
}

func authorizationRequest(auth publishableKey: PublishableKey, deviceID: DeviceID) -> URLRequest {
  let url = URL(string: "\(internalAPIURL.rawValue)/authenticate")!
  var request = URLRequest(url: url)
  request.setValue("Basic \(Data(publishableKey.rawValue.rawValue.utf8).base64EncodedString(options: []))", forHTTPHeaderField: "Authorization")
  request.httpBody = try! JSONSerialization.data(
    withJSONObject: ["device_id" : deviceID.rawValue.rawValue],
    options: JSONSerialization.WritingOptions(rawValue: 0)
  )
  request.httpMethod = "POST"
  return request
}

struct Authentication: Decodable {
  let accessToken: Token
  
  enum CodingKeys: String, CodingKey {
    case accessToken = "access_token"
  }
}

// MARK: - Get History

public func getHistory(_ pk: PublishableKey, _ dID: DeviceID, _ date: Date) -> Effect<Either<History, NonEmptyString>, Never> {
  logEffect("getHistory", failureType: NonEmptyString.self)
    .flatMap { getToken(auth: pk, deviceID: dID) }
    .flatMap { getHistoryFromAPI(auth: $0, deviceID: dID, date: date) }
    .map(Either.left)
    .catch { Just(.right($0)) }
    .eraseToEffect()
}

func getHistoryFromAPI(auth token: Token, deviceID: DeviceID, date: Date) -> AnyPublisher<History, NonEmptyString> {
  URLSession.shared.dataTaskPublisher(for: historyRequest(auth: token, deviceID: deviceID, date: date))
    .map { data, _ in data }
    .decode(type: History.self, decoder: JSONDecoder())
    .mapError { NonEmptyString(rawValue: $0.localizedDescription) ?? NonEmptyString(stringLiteral: "Unknown error") }
    .eraseToAnyPublisher()
}

func historyRequest(auth token: Token, deviceID: DeviceID, date: Date) -> URLRequest {
  let url = URL(string: "\(clientURL.rawValue)/devices/\(deviceID.rawValue.rawValue)/history/\(historyDate(from: date))?timezone=\(TimeZone.current.identifier)")!
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

// MARK: - Get Visits

public func getVisits(_ pk: PublishableKey, _ deID: DeviceID) -> Effect<Either<NonEmptySet<AssignedVisit>, NonEmptyString>, Never> {
  logEffect("getVisits", failureType: NonEmptyString.self)
    .flatMap { getToken(auth: pk, deviceID: deID) }
    .flatMap { t in
      Publishers.Zip(
        getGeofenceAssignedVisits(auth: t, deviceID: deID),
        getTripAssignedVisits(auth: t, deviceID: deID)
      )
    }
    .map { (geofenceVisits, tripVisits) in
      if let nonEmptyVisits = NonEmptySet(rawValue: geofenceVisits.union(tripVisits)) {
        return Either.left(nonEmptyVisits)
      } else {
        return Either.right("Empty result")
      }
    }
    .catch { Just(.right($0)) }
    .eraseToEffect()
}

// MARK: Geofences

func getGeofenceAssignedVisits(auth token: Token, deviceID: DeviceID) -> AnyPublisher<Set<AssignedVisit>, NonEmptyString> {
  getGeofences(auth: token, deviceID: deviceID)
    .map { Set($0.filter { !$0.archived }.map(toAssignedVisit)) }
    .eraseToAnyPublisher()
}

func getGeofences(auth token: Token, deviceID: DeviceID) -> AnyPublisher<[Geofence], NonEmptyString> {
  URLSession.shared.dataTaskPublisher(for: geofencesRequest(auth: token, deviceID: deviceID))
    .map { data, _ in data }
    .decode(type: [Geofence].self, decoder: JSONDecoder())
    .mapError { NonEmptyString(rawValue: $0.localizedDescription) ?? NonEmptyString(stringLiteral: "Unknown error") }
    .eraseToAnyPublisher()
}

func geofencesRequest(auth token: Token, deviceID: DeviceID) -> URLRequest {
  let url = URL(string: "\(clientURL.rawValue)/devices/\(deviceID.rawValue.rawValue)/geofences")!
  var request = URLRequest(url: url)
  request.setValue("Bearer \(token.rawValue.rawValue)", forHTTPHeaderField: "Authorization")
  request.httpMethod = "GET"
  return request
}

struct DynamicKey: CodingKey {
  var intValue: Int?
  var stringValue: String
  
  init?(intValue: Int) {
    self.intValue = intValue
    self.stringValue = "\(intValue)"
  }
  init?(stringValue: String) {
    self.stringValue = stringValue
  }
}

struct Geofence {
  let id: NonEmptyString
  let archived: Bool
  let createdAt: Date
  let coordinate: Coordinate
  let metadata: NonEmptyDictionary<NonEmptyString, NonEmptyString>?
}

extension Geofence: Decodable {
  enum CodingKeys: String, CodingKey {
    case id = "geofence_id"
    case archived
    case createdAt = "created_at"
    case geometry
    case metadata
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    id = try values.decode(NonEmptyString.self, forKey: .id)
    archived = try values.decode(Bool.self, forKey: .archived)
    createdAt = try decodeTimestamp(decoder: decoder, container: values, key: .createdAt)
    coordinate = try decodeGeofenceCentroid(decoder: decoder, container: values, key: .geometry)
    metadata = try decodeMetadata(decoder: decoder, container: values, key: .metadata)
  }
}

func decodeGeofenceCentroid<CodingKey>(
  decoder: Decoder,
  container: KeyedDecodingContainer<CodingKey>,
  key: CodingKey
) throws -> Coordinate {
  let geometryGeoJSON = try container.decode(GeoJSON.self, forKey: key)
  switch geometryGeoJSON {
  case let .point(coordinate):  return coordinate
  case let .polygon(polygon):   return centroid(from: polygon)
  case .lineString:
    throw DecodingError.dataCorrupted(
      DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: "Expected Polygon or Point, but got LineString"
      )
    )
  }
}

func decodeTimestamp<CodingKey>(
  decoder: Decoder,
  container: KeyedDecodingContainer<CodingKey>,
  key: CodingKey
) throws -> Date {
  let dateISO8601 = try container.decode(NonEmptyString.self, forKey: key)
  guard let date = dateISO8601.iso8601 else {
    let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "created_at does not conform to ISO8601 format")
    throw DecodingError.dataCorrupted(context)
  }
  return date
}

func decodeMetadata<CodingKey>(
  decoder: Decoder,
  container: KeyedDecodingContainer<CodingKey>,
  key: CodingKey
) throws -> NonEmptyDictionary<NonEmptyString, NonEmptyString>? {
  if let metadataContainer = try? container.nestedContainer(keyedBy: DynamicKey.self, forKey: key) {
    var mutMetadata: [NonEmptyString: NonEmptyString] = [:]
    for key in metadataContainer.allKeys {
      guard !key.stringValue.hasPrefix("ht_") else { continue }
      
      if let value = try? metadataContainer.decodeIfPresent(String.self, forKey: key),
         let nonEmptyKey = NonEmptyString(rawValue: key.stringValue),
         let nonEmptyValue = NonEmptyString(rawValue: value) {
        mutMetadata[nonEmptyKey] = nonEmptyValue
      }
    }
    return NonEmptyDictionary(rawValue: mutMetadata)
  } else {
    return nil
  }
}
  
func toAssignedVisit(_ geofenceVisit: Geofence) -> AssignedVisit {
  let canBeEmptyMetadata = geofenceVisit.metadata?.reduce(into: [:]) { (result: inout [AssignedVisit.Name: AssignedVisit.Contents], tuple: (key: NonEmptyString, value: NonEmptyString)) in
    result[.init(rawValue: tuple.key)] = .init(rawValue: tuple.value)
  }
  let metadata: NonEmptyDictionary<AssignedVisit.Name, AssignedVisit.Contents>?
  if let canBeEmptyMetadata = canBeEmptyMetadata {
    metadata = NonEmptyDictionary(rawValue: canBeEmptyMetadata)
  } else {
    metadata = nil
  }
  
  return AssignedVisit(
    id: AssignedVisit.ID(rawValue: geofenceVisit.id),
    createdAt: geofenceVisit.createdAt,
    source: .geofence,
    location: geofenceVisit.coordinate,
    geotagSent: .notSent,
    noteFieldFocused: false,
    metadata: metadata
  )
}

func centroid(from linearRings: NonEmptyArray<LinearRing>) -> Coordinate {
  let points = linearRings.flatMap { [$0.origin] + [$0.first] + [$0.second] + $0.rest }
  
  var x:Float = 0.0
  var y:Float = 0.0
  var z:Float = 0.0
  for point in points {
    let lat = GLKMathDegreesToRadians(Float(point.latitude))
    let long = GLKMathDegreesToRadians(Float(point.longitude))
    
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
  let result = Coordinate(
    latitude: CLLocationDegrees(GLKMathRadiansToDegrees(Float(resultLat))),
    longitude: CLLocationDegrees(GLKMathRadiansToDegrees(Float(resultLong)))
  )
  return result!
}

// MARK Trips

func getTripAssignedVisits(auth token: Token, deviceID: DeviceID) -> AnyPublisher<Set<AssignedVisit>, NonEmptyString> {
  getTrips(auth: token, deviceID: deviceID)
    .map { Set($0.map(toAssignedVisit)) }
    .eraseToAnyPublisher()
}

func getTrips(auth token: Token, deviceID: DeviceID) -> AnyPublisher<[Trip], NonEmptyString> {
  let paginationPublisher = CurrentValueSubject<NonEmptyString?, Never>(nil)
  
  return paginationPublisher
    .setFailureType(to: NonEmptyString.self)
    .flatMap { paginationToken in
      getTripsPage(auth: token, deviceID: deviceID, paginationToken: paginationToken)
    }
    .handleEvents(receiveOutput: { page in
      if let paginationToken = page.paginationToken {
        paginationPublisher.send(paginationToken)
      } else {
        paginationPublisher.send(completion: .finished)
      }
    })
    .reduce([Trip](), { allTrips, page in
      page.trips + allTrips
    })
    .eraseToAnyPublisher()
}

func getTripsPage(auth token: Token, deviceID: DeviceID, paginationToken: NonEmptyString?) -> AnyPublisher<TripsPage, NonEmptyString> {
  URLSession.shared.dataTaskPublisher(for: tripsRequest(auth: token, deviceID: deviceID, paginationToken: paginationToken))
    .map { data, _ in data }
    .decode(type: TripsPage.self, decoder: JSONDecoder())
    .mapError { NonEmptyString(rawValue: $0.localizedDescription) ?? NonEmptyString(stringLiteral: "Unknown error") }
    .eraseToAnyPublisher()
}

func tripsRequest(auth token: Token, deviceID: DeviceID, paginationToken: NonEmptyString?) -> URLRequest {
  var urlString = "\(clientURL.rawValue)/trips?device_id=\(deviceID.rawValue.rawValue)"
  if let paginationToken = paginationToken {
    urlString += "&pagination_token=\(paginationToken.rawValue)"
  }
  var request = URLRequest(url: URL(string: urlString)!)
  request.setValue("Bearer \(token.rawValue.rawValue)", forHTTPHeaderField: "Authorization")
  request.httpMethod = "GET"
  return request
}

struct TripsPage {
  let trips: [Trip]
  let paginationToken: NonEmptyString?
}
  
struct Trip: Hashable {
  let id: NonEmptyString
  let createdAt: Date
  let coordinate: Coordinate
  let metadata: NonEmptyDictionary<NonEmptyString, NonEmptyString>?
}


extension TripsPage: Decodable {
  enum CodingKeys: String, CodingKey {
    case data
    case paginationToken = "pagination_token"
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    trips = try values.decode([Trip].self, forKey: .data)
    paginationToken = try? values.decodeIfPresent(NonEmptyString.self, forKey: .paginationToken)
  }
}

extension Trip: Decodable {
  enum CodingKeys: String, CodingKey {
    case id = "trip_id"
    case createdAt = "started_at"
    case destination
    case metadata
  }
  
  enum DestinationCodingKeys: String, CodingKey {
    case geometry
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    id = try values.decode(NonEmptyString.self, forKey: .id)
    createdAt = try decodeTimestamp(decoder: decoder, container: values, key: .createdAt)
    let destinationJSON = try values.nestedContainer(keyedBy: DestinationCodingKeys.self, forKey: .destination)
    coordinate = try decodeGeofenceCentroid(decoder: decoder, container: destinationJSON, key: .geometry)
    metadata = try decodeMetadata(decoder: decoder, container: values, key: .metadata)
  }
}

func toAssignedVisit(_ tripVisit: Trip) -> AssignedVisit {
  AssignedVisit(
    id: AssignedVisit.ID(rawValue: tripVisit.id),
    createdAt: tripVisit.createdAt,
    source: .trip,
    location: tripVisit.coordinate,
    geotagSent: .notSent,
    noteFieldFocused: false
  )
}

// MARK: - Reverse Geocoding

public func reverseGeocode(_ coordinates: [Coordinate]) -> Effect<[(Coordinate, These<AssignedVisit.Street, AssignedVisit.FullAddress>?)], Never> {
  coordinates.publisher
    .flatMap { reverseGeocodeCoordinate($0) }
    .collect()
    .eraseToEffect()
}


func reverseGeocodeCoordinate(_ coordinate: Coordinate) -> AnyPublisher<(Coordinate, These<AssignedVisit.Street, AssignedVisit.FullAddress>?), Never> {
  Future { promise in
    reverseGeocodeLocation(coordinate) {
      if let address = $0 {
        promise(.success((coordinate, address)))
      } else {
        promise(.success((coordinate, nil)))
      }
    }
  }
  .eraseToAnyPublisher()
}

func reverseGeocodeLocation(_ coordinate: Coordinate, completion: @escaping (These<AssignedVisit.Street, AssignedVisit.FullAddress>?) -> Void) {
  let locaiton = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
  CLGeocoder().reverseGeocodeLocation(locaiton) { placemarks, error in
    guard error == nil, let first = placemarks?.first else {
      completion(nil)
      return
    }
    completion(
      constructAddress(
        fromSubThoroughfare: first.subThoroughfare,
        thoroughfare: first.thoroughfare,
        formattedAddress: first.formattedAddress
      )
    )
  }
}

func constructAddress(
  fromSubThoroughfare subThoroughfare: String?,
  thoroughfare: String?,
  formattedAddress: String?
) -> These<AssignedVisit.Street, AssignedVisit.FullAddress>? {
  let streetString: String? = { streetNumber in { streetName in "\(streetNumber) \(streetName)" } }
    <!> subThoroughfare
    <*> thoroughfare
    <|> thoroughfare
  let fullAddressString = formattedAddress
  
  
  let street = streetString
    >>- NonEmptyString.init(rawValue:)
    <¡> AssignedVisit.Street.init(rawValue:)
  
  let fullAddress = fullAddressString
    >>- NonEmptyString.init(rawValue:)
    <¡> AssignedVisit.FullAddress.init(rawValue:)
  
  return maybeThese(street)(fullAddress)
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

// MARK: - Logging

func prettyPrint(data: Data, response: URLResponse) {
  let responseData: String
  if let prettyData = prettyPrintJSONData(data) {
    responseData = prettyData
  } else {
    responseData = "Can't parse data to JSON"
  }
  
  if let httpResponse = response as? HTTPURLResponse {
    let headers = prettyPrintHTTPURLResponseHeaders(
      httpResponse.allHeaderFields
    )
    
    let string = """
    History Response: \(responseData)

    \("Status code: \(httpResponse.statusCode)")
    \("Headers: \(headers)")
    """
    print(string)
  } else {
    print("History Response: \(responseData)")
  }
}

let prettyPrintedOptionalNone = "nil"

func prettyPrintHTTPURLResponse(_ response: HTTPURLResponse?) -> String {
  switch response {
    case .none:
      return prettyPrintedOptionalNone
    case let .some(httpURLResponse):
      let headers = prettyPrintHTTPURLResponseHeaders(
        httpURLResponse.allHeaderFields
      )

      let string = """

      \("Status code: \(httpURLResponse.statusCode)")
      \("Headers: \(headers)")

      """
      return string
  }
}

func prettyPrintHTTPURLResponseHeaders(_ headers: [AnyHashable: Any]) -> String
{ headers.reduce("", headerReducer) }

func headerReducer(sum: String, header: (key: AnyHashable, value: Any)) -> String
{ sum + "\n\(header.key): \(header.value)" }

func prettyPrintJSONData(_ jsonData: Data) -> String? {
  guard
    let object = try? JSONSerialization.jsonObject(with: jsonData, options: []),
    let data = try? JSONSerialization.data(
      withJSONObject: object,
      options: [.prettyPrinted]
    ), let prettyPrintedString = String(data: data, encoding: .utf8)
  else { return nil }
  return prettyPrintedString
}
