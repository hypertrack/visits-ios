import APIEnvironment
import Combine
import ComposableArchitecture
import Foundation
import LogEnvironment
import NonEmpty
import Tagged
import Types
import Utility
import PlacesScreen

func getVisits(_ token: Token.Value, _ wh: WorkerHandle, from: Date, to: Date) -> Effect<Result<VisitsData, APIError<Token.Expired>>, Never> {
  logEffect("getVisits")

  return Publishers.Zip(
    callAPI(
      request: placesVisitsRequest(auth: token, workerHandle: wh, from: from, to: to, paginationToken: nil),
      success: VisitsResponse.self
    ).mapError(fromNever)
        .eraseToAnyPublisher(),
    callAPI(
      request: workerSummaryRequest(auth: token, workerHandle: wh, from: from, to: to),
      success: RemoteWorker.self
    ).mapError(fromNever)
        .eraseToAnyPublisher()
  )
  .map(toPlacesVisitsSummary(from: from, to: to, wh))
  .mapError(fromNever)
  .eraseToAnyPublisher()
  .catchToEffect()
}

private func taggedDate<Tag>(hour: Int, minute: Int, second: Int) -> Tagged<Tag, Date> {
  .init(rawValue: date(hour: hour, minute: minute, second: second))
}

private func date(hour: Int, minute: Int, second: Int) -> Date {
  Calendar.current.date(bySettingHour: hour, minute: minute, second: second, of: Date())!
}

func toPlacesVisitsSummary(from: Date, to: Date, _ workerHandle: WorkerHandle) -> (VisitsResponse, RemoteWorker) -> VisitsData {
    { visitsResponse, worker  in
    let visits: [RemoteVisit] = visitsResponse.orders?.compactMap { $0.visits }.flatMap { $0 } ?? []
    return VisitsData(
      from: from,
      to: to,
      summary: .init(
        timeSpentInsideGeofences: worker.summary?.timeSpentInsideGeofences ?? 0,
        totalDriveDistance: worker.summary?.totalDriveDistance ?? 0,
        // ignoring remote visits number to avoid data mismatch
        visitsNumber: visits.count,
        // this value is not present in the response, counting locally
        visitedPlacesNumber: Set(visits.compactMap { $0.geofenceAddress }).count
      ),
      visits: visits.compactMap { remoteVisit in
        if let visitId = remoteVisit.visitId,
          case let .some(id) = NonEmptyString(rawValue: visitId),
                let arrival = remoteVisit.arrival,
                let arrivalDate = arrival.recordedAt,
                let enroute = remoteVisit.enroute,
                let distance = enroute.distance,
                let duration = enroute.duration,
                let idleTime = enroute.idleTime
        {
          let addressValue: NonEmptyString?
          if let address = remoteVisit.geofenceAddress {
            addressValue = .init(rawValue: address)
          } else {
            addressValue = nil
          }

          let exitDate = remoteVisit.exit?.recordedAt
          let exitValue: PlaceVisit.ExitTimestamp?
          if exitDate != nil {
            exitValue = .init(rawValue: exitDate!)
          } else {
            exitValue = nil
          }
          return PlaceVisit(
            address: addressValue,
            duration: safeAbsoluteDuration(from: arrivalDate, to: exitDate ?? Date()),
            entry: .init(rawValue: arrivalDate),
            exit: exitValue,
            id: .init(rawValue: id),
            route: .init(
              distance: .init(rawValue: distance),
              duration: .init(rawValue: duration),
              idleTime: .init(rawValue: idleTime)
            )
          )
        } else {
          return nil
        }
      }, workerHandle: workerHandle
    )
  }
}

func placesVisitsRequest(auth token: Token.Value, workerHandle: WorkerHandle, from: Date, to: Date, paginationToken: PaginationToken?) -> URLRequest {
  var components = URLComponents()
  components.scheme = "https"
  components.host = "live-app-backend.htprod.hypertrack.com"
  components.path = "/client/visits"

  let iso8601Formatter = ISO8601DateFormatter()
  iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

  components.queryItems = [
    URLQueryItem(name: "worker_handle", value: workerHandle.string),
    URLQueryItem(name: "visited_at_from", value: DateFormatter.iso8601MillisecondsDateFormatter.string(from: from)),
    URLQueryItem(name: "visited_at_to", value: DateFormatter.iso8601MillisecondsDateFormatter.string(from: to)),
  ]
  if let paginationToken = paginationToken, let queryItems = components.queryItems {
    components.queryItems = queryItems + [
      URLQueryItem(name: "pagination_token", value: "\(paginationToken)"),
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
}

struct VisitOrderWrapper: Decodable {
  let visits: [RemoteVisit]?
}

struct RemoteVisit: Decodable {
  let arrival: GeofenceCrossing?
  let enroute: Enroute?
  let exit: GeofenceCrossing?
  let geofenceAddress: String?
  let geofenceMetadata: JSON?
  let visitId: String?
}

struct Enroute: Decodable {
  let distance: UInt?
  let duration: UInt?
  let idleTime: UInt?
}

struct GeofenceCrossing: Decodable {
  let recordedAt: Date?
}

extension VisitsResponse {
  enum CodingKeys: String, CodingKey {
    case orders
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    orders = try container.decodeIfPresent([VisitOrderWrapper].self, forKey: .orders)
  }
}

extension VisitOrderWrapper {
  enum CodingKeys: String, CodingKey {
    case visits
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    visits = try container.decodeIfPresent([RemoteVisit].self, forKey: .visits)
  }
}

extension RemoteVisit {
  enum CodingKeys: String, CodingKey {
    case arrival
    case enroute
    case exit
    case geofenceAddress = "geofence_address"
    case geofenceMetadata = "geofence_metadata"
    case visitId = "visit_id"
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    arrival = try container.decodeIfPresent(GeofenceCrossing.self, forKey: .arrival)
    enroute = try container.decodeIfPresent(Enroute.self, forKey: .enroute)
    exit = try container.decodeIfPresent(GeofenceCrossing.self, forKey: .exit)
    geofenceAddress = try container.decodeIfPresent(String.self, forKey: .geofenceAddress)
    geofenceMetadata = try container.decodeIfPresent(JSON.self, forKey: .geofenceMetadata)
    visitId = try container.decodeIfPresent(String.self, forKey: .visitId)
  }
}

extension Enroute {
  enum CodingKeys: String, CodingKey {
    case distance
    case duration
    case idleTime = "idle_time"
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    distance = try container.decodeIfPresent(UInt.self, forKey: .distance)
    duration = try container.decodeIfPresent(UInt.self, forKey: .duration)
    idleTime = try container.decodeIfPresent(UInt.self, forKey: .idleTime)
  }
}

extension GeofenceCrossing {
  enum CodingKeys: String, CodingKey {
    case recordedAt = "recorded_at"
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    recordedAt = try decodeTimestamp(decoder: decoder, container: container, key: .recordedAt)
  }
}

