import APIEnvironment
import Combine
import Foundation
import NonEmpty
import Tagged
import Types


func getTrips(auth token: Token.Value, deviceID: DeviceID) -> AnyPublisher<[Trip], APIError<Token.Expired>> {
  paginate(
    getPage: { pagination in
      callAPI(
        request: tripsRequest(auth: token, deviceID: deviceID, paginationToken: pagination),
        success: TripsPage.self,
        failure: Token.Expired.self
      )
    },
    valuesFromPage: \.trips,
    paginationFromPage: \.paginationToken
  )
}

func tripsRequest(auth token: Token.Value, deviceID: DeviceID, paginationToken: PaginationToken?) -> URLRequest {
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
  let status: Status
  let orders: [Order]
  
  enum Status { case active, completed, processingCompletion }
}

extension Order: Decodable {
  enum CodingKeys: String, CodingKey {
    case id = "order_id"
    case createdAt = "started_at"
    case completedAt = "completed_at"
    case destination
    case metadata
    case status
    case arrivedAt = "arrived_at"
    case exitedAt = "exited_at"
    
    enum DestinationCodingKeys: String, CodingKey { case geometry, address }
    
    enum MetadataCodingKeys: String, CodingKey {
      case visitsApp = "visits_app"
      enum VisitsAppCodingKeys: String, CodingKey { case note }
    }
  }
  
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    let id = try values.decode(ID.self, forKey: .id)
    let tripID:Order.TripID = "STUB"
    
    let createdAt = try decodeTimestamp(decoder: decoder, container: values, key: .createdAt)
    
    let destinationJSON = try values.nestedContainer(keyedBy: CodingKeys.DestinationCodingKeys.self, forKey: .destination)
    let location = try decodeGeofenceCentroid(decoder: decoder, container: destinationJSON, key: .geometry)
    
    let addressString = try destinationJSON.decode(String.self, forKey: .address)
    let address = Address(string: addressString)
    
    let statusString = try values.decode(String.self, forKey: .status)
    let status: Order.Status
    switch statusString {
    case "ongoing":
      status = .ongoing(.unfocused)
    case "completed":
      let completedDate = try decodeTimestamp(decoder: decoder, container: values, key: .completedAt)
      status = .completed(completedDate)
    case "cancelled":
      status = .cancelled
    case "disabled":
      status = .disabled
    default:
      throw DecodingError.dataCorrupted(
        .init(codingPath: decoder.codingPath, debugDescription: "Unrecognized order status: \(statusString)")
      )
    }
    
    let note: Order.Note?
    if let metadataContainer = try? values.nestedContainer(keyedBy: CodingKeys.MetadataCodingKeys.self, forKey: .metadata),
       let visitsAppContainer = try? metadataContainer.nestedContainer(keyedBy: CodingKeys.MetadataCodingKeys.VisitsAppCodingKeys.self, forKey: .visitsApp) {
      note = try? visitsAppContainer.decode(Note.self, forKey: .note)
    } else {
      note = nil
    }
    
    let arrivedAt = try? decodeTimestamp(decoder: decoder, container: values, key: .arrivedAt)
    let exitedAt = try? decodeTimestamp(decoder: decoder, container: values, key: .exitedAt)
    let visited: Order.Visited?
    switch (arrivedAt, exitedAt) {
    case let (.some(arrivedAt), .some(exitedAt)):
      visited = .visited(arrivedAt, exitedAt)
    case let (.some(arrivedAt), .none):
      visited = .entered(arrivedAt)
    case (.none, .some), (.none, .none):
      visited = nil
    }
    
    let metadata = repackageMetadata(try decodeMetadata(decoder: decoder, container: values, key: .metadata))
    
    self.init(
      id: id,
      tripID: tripID,
      createdAt: createdAt,
      location: location,
      address: address,
      status: status,
      note: note,
      visited: visited,
      metadata: metadata
    )
  }
}

func repackageMetadata(_ metadata: NonEmptyDictionary<NonEmptyString, NonEmptyString>?) -> [Order.Name: Order.Contents] {
  switch metadata {
  case let .some(metadata):
    return Dictionary(
      uniqueKeysWithValues: metadata.rawValue.map { (Order.Name(rawValue: $0), Order.Contents(rawValue: $1)) }
    )
  case .none: return [:]
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
    case status
    case orders
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    id = try values.decode(NonEmptyString.self, forKey: .id)
    
    createdAt = try decodeTimestamp(decoder: decoder, container: values, key: .createdAt)
    
    let statusString = try values.decode(String.self, forKey: .status)
    switch statusString {
    case "active":                status = .active
    case "completed":             status = .completed
    case "processing_completion": status = .processingCompletion
    default:
      throw DecodingError.dataCorrupted(
        .init(codingPath: decoder.codingPath, debugDescription: "Unrecognized trip status: \(statusString)")
      )
    }
    orders = try values.decodeIfPresent([Order].self, forKey: .orders) ?? []
  }
}
