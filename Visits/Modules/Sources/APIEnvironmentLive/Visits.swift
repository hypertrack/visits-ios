import APIEnvironment
import Combine
import ComposableArchitecture
import Foundation
import LogEnvironment
import NonEmpty
import Tagged
import Types
import Utility

func getVisits(_ token: Token.Value, _ wh: WorkerHandle, _ from: Date, _ to: Date) -> Effect<Result<PlacesVisitsSummary, APIError<Token.Expired>>, Never> {
  logEffect("getVisits")

  return callAPI(
    request: placesVisitsRequest(auth: token, workerHandle: wh, from: from, to: to, paginationToken: nil),
    success: VisitsResponse.self
  )
  .mapError(fromNever)
  .map(toPlacesVisitsSummary())
  .eraseToAnyPublisher()
  .catchToEffect()
}

private let cityHall = Place(
  id: "1",
  address: .init(street: "San Francisco City Hall", fullAddress: "San Francisco City Hall, 400 Van Ness Ave, San Francisco, CA  94102, United States"),
  createdAt: taggedDate(hour: 9, minute: 0, second: 0),
  currentlyInside: nil,
  metadata: ["name": "City Hall"],
  shape: .circle(.init(center: Coordinate(latitude: 37.779272, longitude: -122.419148)!, radius: 100)),
  visits: [
    .init(
      id: "1",
      entry: taggedDate(hour: 9, minute: 10, second: 50),
      exit: taggedDate(hour: 9, minute: 15, second: 50),
      route: .init(
        distance: .init(rawValue: 1234),
        duration: .init(rawValue: 1234),
        idleTime: .init(rawValue: 123)
      )
    )
  ]
)

private func taggedDate<Tag>(hour: Int, minute: Int, second: Int) -> Tagged<Tag, Date> {
  .init(rawValue: date(hour: hour, minute: minute, second: second))
}

private func date(hour: Int, minute: Int, second: Int) -> Date {
  Calendar.current.date(bySettingHour: hour, minute: minute, second: second, of: Date())!
}

func toPlacesVisitsSummary() -> (VisitsResponse) -> PlacesVisitsSummary {
  { response in
    let visits: [String] = response.orders?.compactMap { $0.visits?.compactMap { $0.visitId } }.flatMap { $0 } ?? []
      return PlacesVisitsSummary(visits: visits.map { remoteVisit in
          let id = NonEmptyString.init(rawValue: remoteVisit)!
          return Place.Visit.init(
            id: .init(rawValue: id),
            entry: taggedDate(hour: 9, minute: 10, second: 50),
            exit: taggedDate(hour: 9, minute: 15, second: 50),
            route: .init(
              distance: .init(rawValue: 1234),
              duration: .init(rawValue: 1234),
              idleTime: .init(rawValue: 123)
            )
          )
      })
  }
}

func placesVisitsRequest(auth token: Token.Value, workerHandle: WorkerHandle,  from: Date, to: Date, paginationToken: PaginationToken?) -> URLRequest {
  var components = URLComponents()
  components.scheme = "https"
  components.host = "live-app-backend.htprod.hypertrack.com"
  components.path = "/client/visits"
    
    let iso8601String = "2024-12-09T17:00:04.988Z"
    let iso8601String1 = "2024-12-18T17:10:04.988Z"

    // Use ISO8601DateFormatter for this format
    let iso8601Formatter = ISO8601DateFormatter()
    iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

    let date = iso8601Formatter.date(from: iso8601String)!
    let date1 = iso8601Formatter.date(from: iso8601String1)!
    
  components.queryItems = [
    URLQueryItem(name: "worker_handle", value: workerHandle.string),
    URLQueryItem(name: "visited_at_from", value: DateFormatter.iso8601MillisecondsDateFormatter.string(from: date)),
    URLQueryItem(name: "visited_at_to", value: DateFormatter.iso8601MillisecondsDateFormatter.string(from: date1))
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

struct VisitsResponse: Decodable {
    let orders: [VisitOrderWrapper]?

    enum CodingKeys: String, CodingKey {
        case orders = "orders"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        orders = try container.decodeIfPresent([VisitOrderWrapper].self, forKey: .orders)
    }
}

struct VisitOrderWrapper: Decodable {
    let visits: [RemoteVisit]?

    enum CodingKeys: String, CodingKey {
        case visits = "visits"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        visits = try container.decodeIfPresent([RemoteVisit].self, forKey: .visits)
    }
}

struct RemoteVisit: Decodable {
    let visitId: String?

    enum CodingKeys: String, CodingKey {
        case visitId = "visit_id"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        visitId = try container.decodeIfPresent(String.self, forKey: .visitId)
    }

}
