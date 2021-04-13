import APIEnvironment
import Combine
import Foundation
import NonEmpty
import Tagged
import Types


func getTrips(auth token: Token, deviceID: DeviceID) -> AnyPublisher<[Trip], APIError<Never>> {
  paginate(
    getPage: { pagination in
      callAPI(
        request: tripsRequest(auth: token, deviceID: deviceID, paginationToken: pagination),
        success: TripsPage.self
      )
    },
    valuesFromPage: \.trips,
    paginationFromPage: \.paginationToken
  )
}

func tripsRequest(auth token: Token, deviceID: DeviceID, paginationToken: PaginationToken?) -> URLRequest {
  var urlString = "\(clientURL)/trips?device_id=\(deviceID)"
  if let paginationToken = paginationToken {
    urlString += "&pagination_token=\(paginationToken)"
  }
  var request = URLRequest(url: URL(string: urlString)!)
  request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
  request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
  request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
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
  let orders: [_Order]
}

struct _Order {
  let id: NonEmptyString
  let coordinate: Coordinate
  let metadata: NonEmptyDictionary<NonEmptyString, NonEmptyString>?
  let visitStatus: VisitStatus?
}

extension _Order: Decodable {
  enum CodingKeys: String, CodingKey {
    case id = "order_id"
    case destination
    case metadata
    case arrivedAt = "arrived_at"
    case exitedAt = "exited_at"
  }
  
  enum DestinationCodingKeys: String, CodingKey {
    case geometry
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    id = try values.decode(NonEmptyString.self, forKey: .id)
    
    let arrivedAt = try? decodeTimestamp(decoder: decoder, container: values, key: .arrivedAt)
    let exitedAt = try? decodeTimestamp(decoder: decoder, container: values, key: .exitedAt)
    
    switch (arrivedAt, exitedAt) {
    case let (.some(arrivedAt), .some(exitedAt)):
      visitStatus = .visited(arrivedAt, exitedAt)
    case let (.some(arrivedAt), .none):
      visitStatus = .entered(arrivedAt)
    case (.none, .some), (.none, .none):
      visitStatus = nil
    }
    
    let destinationJSON = try values.nestedContainer(keyedBy: DestinationCodingKeys.self, forKey: .destination)
    
    coordinate = try decodeGeofenceCentroid(decoder: decoder, container: destinationJSON, key: .geometry)
    
    metadata = try decodeMetadata(decoder: decoder, container: values, key: .metadata)
  }
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
    case orders
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
    
    orders = (try? values.decodeIfPresent([_Order].self, forKey: .orders)) ?? []
  }
}
