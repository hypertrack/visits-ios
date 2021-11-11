import AppArchitecture
import ComposableArchitecture
import APIEnvironment
import Utility
import Combine
import Foundation
import NonEmpty
import Tagged
import Types

func getTrip(_ token: Token.Value, _ deID: DeviceID) -> Effect<Result<Trip?, APIError<Token.Expired>>, Never> {
  return getTrips(auth: token, deviceID: deID)
      .map { trips in
        trips
          .filter { $0.status == .active && !$0.orders.isEmpty && $0.id != unassignedTrip }
          .sorted(by: \.createdAt)
          .first
      }
      .catchToEffect()
}

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

    guard id.string.rangeOfCharacter(from: .whitespacesAndNewlines) == nil else {
      throw DecodingError.dataCorrupted(
        .init(
          codingPath: decoder.codingPath,
          debugDescription: #"Order ID can't contain whitespaces or new lines. Received ID: "\#(id.string)""#
        )
      )
    }
    
    let createdAt = try decodeTimestamp(decoder: decoder, container: values, key: .createdAt)
    
    let destinationJSON = try values.nestedContainer(keyedBy: CodingKeys.DestinationCodingKeys.self, forKey: .destination)
    let location = try decodeGeofenceCentroid(decoder: decoder, container: destinationJSON, key: .geometry)
    
    let addressString = try destinationJSON.decode(String.self, forKey: .address)
    let address = Address(string: addressString)
    
    let statusString = try values.decode(String.self, forKey: .status)
    let status: Order.Status
    switch statusString {
    case "assigned", "ongoing":
      status = .ongoing(.unfocused)
    case "completed":
      let completedDate = try decodeTimestamp(decoder: decoder, container: values, key: .completedAt)
      status = .completed(completedDate)
    case "cancelled":
      status = .cancelled
    case "snoozed":
      status = .snoozed
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

    self.init(
      id: id,
      createdAt: createdAt,
      location: location,
      address: address,
      status: status,
      note: note,
      visited: visited,
      metadata: wrapDictionary(try decodeMetadata(decoder: decoder, container: values, key: .metadata))
    )
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
    case metadata
  }
  
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    let id = (try? values.decode(ID.self, forKey: .id)) ?? unassignedTrip

    guard id.string.rangeOfCharacter(from: .whitespacesAndNewlines) == nil else {
      throw DecodingError.dataCorrupted(
        .init(
          codingPath: decoder.codingPath,
          debugDescription: #"Trip ID can't contain whitespaces or new lines. Received ID: "\#(id.string)""#
        )
      )
    }
    
    let createdAt = try decodeTimestamp(decoder: decoder, container: values, key: .createdAt)
    
    var status: Trip.Status
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
    let orders = try values.decodeIfPresent([Order].self, forKey: .orders) ?? []

    self.init(
      id: id,
      createdAt: createdAt,
      status: status,
      orders: orders,
      metadata: wrapDictionary(try decodeMetadata(decoder: decoder, container: values, key: .metadata))
    )
  }
}

private let unassignedTrip: Trip.ID = "UNASSIGNED"
