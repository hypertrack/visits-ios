import APIEnvironment
import Combine
import ComposableArchitecture
import LogEnvironment
import NonEmpty
import Prelude
import Types


func getVisits(_ pk: PublishableKey, _ deID: DeviceID) -> Effect<Result<[APIVisitID: APIVisit], APIError>, Never> {
  logEffect("getVisits", failureType: APIError.self)
    .flatMap { getToken(auth: pk, deviceID: deID) }
    .flatMap { t in
      getTrips(auth: t, deviceID: deID)
        .map { trips in
          trips.flatMap(apiVisit(fromTrip:))
        }
    }
    .map { Dictionary(uniqueKeysWithValues: ($0)) }
    .map(Result.success)
    .catch(Result.failure >>> Just.init(_:))
    .eraseToEffect()
}

func apiVisit(fromTrip trip: Trip) -> [(APIVisitID, APIVisit)] {
  if trip.orders.isEmpty {
    return [
      (
        APIVisitID(rawValue: trip.id),
        APIVisit(
          centroid: trip.coordinate,
          createdAt: trip.createdAt,
          metadata: repackageMetadata(trip.metadata),
          source: .trip,
          visited: trip.visitStatus
        )
      )
    ]
  } else {
    var createdAt = trip.createdAt
    var orders: [(APIVisitID, APIVisit)] = []
    for order in trip.orders {
      orders += [
        (
          APIVisitID(rawValue: order.id),
          APIVisit(
            centroid: order.coordinate,
            createdAt: createdAt,
            metadata: repackageMetadata(order.metadata),
            source: .order,
            visited: order.visitStatus
          )
        )
      ]
      createdAt = createdAt.advanced(by: 0.001)
    }
    return orders
  }
}

func repackageMetadata(_ metadata: NonEmptyDictionary<NonEmptyString, NonEmptyString>?) -> [APIVisit.Name: APIVisit.Contents] {
  switch metadata {
  case let .some(metadata):
    return Dictionary(
      uniqueKeysWithValues: metadata.rawValue.map { (APIVisit.Name(rawValue: $0), APIVisit.Contents(rawValue: $1)) }
    )
  case .none: return [:]
  }
}
