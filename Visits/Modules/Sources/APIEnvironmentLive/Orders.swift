import APIEnvironment
import Combine
import ComposableArchitecture
import LogEnvironment
import NonEmpty
import Utility
import Types


func getOrders(_ pk: PublishableKey, _ deID: DeviceID) -> Effect<Result<[APIOrderID: APIOrder], APIError<Never>>, Never> {
  logEffect("getOrders", failureType: APIError<Never>.self)
    .flatMap { getToken(auth: pk, deviceID: deID) }
    .flatMap {
      getTrips(auth: $0, deviceID: deID)
        .map { trips in
          trips.flatMap(apiOrder(fromTrip:))
        }
    }
    .map { Dictionary(uniqueKeysWithValues: ($0)) }
    .catchToEffect()
}

func apiOrder(fromTrip trip: Trip) -> [(APIOrderID, APIOrder)] {
  if trip.orders.isEmpty {
    return [
      (
        APIOrderID(rawValue: trip.id),
        APIOrder(
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
    var orders: [(APIOrderID, APIOrder)] = []
    for order in trip.orders {
      orders += [
        (
          APIOrderID(rawValue: order.id),
          APIOrder(
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

func repackageMetadata(_ metadata: NonEmptyDictionary<NonEmptyString, NonEmptyString>?) -> [APIOrder.Name: APIOrder.Contents] {
  switch metadata {
  case let .some(metadata):
    return Dictionary(
      uniqueKeysWithValues: metadata.rawValue.map { (APIOrder.Name(rawValue: $0), APIOrder.Contents(rawValue: $1)) }
    )
  case .none: return [:]
  }
}
