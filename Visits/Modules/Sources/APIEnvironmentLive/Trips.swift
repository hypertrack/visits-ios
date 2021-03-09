import APIEnvironment
import Combine
import Coordinate
import DeviceID
import Foundation
import NonEmpty
import Tagged
import Visit


func getTrips(auth token: Token, deviceID: DeviceID) -> AnyPublisher<[Trip], APIError> {
  paginate(
    getPage: { pagination in
      getTripsPage(auth: token, deviceID: deviceID, paginationToken: pagination)
    },
    valuesFromPage: \.trips,
    paginationFromPage: \.paginationToken
  )
}

func getTripsPage(auth token: Token, deviceID: DeviceID, paginationToken: PaginationToken?) -> AnyPublisher<TripsPage, APIError> {
  URLSession.shared.dataTaskPublisher(for: tripsRequest(auth: token, deviceID: deviceID, paginationToken: paginationToken))
    .map { data, _ in data }
    .decode(type: TripsPage.self, decoder: JSONDecoder())
    .mapError { _ in .unknown }
    .eraseToAnyPublisher()
}

func tripsRequest(auth token: Token, deviceID: DeviceID, paginationToken: PaginationToken?) -> URLRequest {
  var urlString = "\(clientURL)/trips?device_id=\(deviceID)"
  if let paginationToken = paginationToken {
    urlString += "&pagination_token=\(paginationToken)"
  }
  var request = URLRequest(url: URL(string: urlString)!)
  request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
  request.httpMethod = "GET"
  return request
}

struct TripsPage {
  let trips: [Trip]
  let paginationToken: PaginationToken?
}
  
struct Trip {
  let id: NonEmptyString
  let createdAt: Date
  let coordinate: Coordinate
  let metadata: NonEmptyDictionary<NonEmptyString, NonEmptyString>?
  let visitStatus: VisitStatus?
}


extension TripsPage: Decodable {
  enum CodingKeys: String, CodingKey {
    case data
    case paginationToken = "pagination_token"
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    trips = try values.decode([Trip].self, forKey: .data)
    paginationToken = try? values.decodeIfPresent(PaginationToken.self, forKey: .paginationToken)
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
    case arrivedAt = "arrived_at"
    case exitedAt = "exited_at"
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    id = try values.decode(NonEmptyString.self, forKey: .id)
    
    createdAt = try decodeTimestamp(decoder: decoder, container: values, key: .createdAt)
    
    let destinationJSON = try values.nestedContainer(keyedBy: DestinationCodingKeys.self, forKey: .destination)
    
    coordinate = try decodeGeofenceCentroid(decoder: decoder, container: destinationJSON, key: .geometry)
    
    let arrivedAt = try? decodeTimestamp(decoder: decoder, container: destinationJSON, key: .arrivedAt)
    let exitedAt = try? decodeTimestamp(decoder: decoder, container: destinationJSON, key: .exitedAt)
    switch (arrivedAt, exitedAt) {
    case let (.some(arrivedAt), .some(exitedAt)):
      visitStatus = .visited(arrivedAt, exitedAt)
    case let (.some(arrivedAt), .none):
      visitStatus = .entered(arrivedAt)
    case (.none, .some), (.none, .none):
      visitStatus = nil
    }
    
    metadata = try decodeMetadata(decoder: decoder, container: values, key: .metadata)
  }
}
