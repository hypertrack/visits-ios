import APIEnvironment
import DeviceID
import Combine
import ComposableArchitecture
import Log
import NonEmpty
import Prelude
import PublishableKey
import Visit


public func getVisits(_ pk: PublishableKey, _ deID: DeviceID) -> Effect<Result<[APIVisitID: APIVisit], APIError>, Never> {
  logEffect("getVisits", failureType: APIError.self)
    .flatMap { getToken(auth: pk, deviceID: deID) }
    .flatMap { t in
      Publishers.Zip(
        getGeofences(auth: t, deviceID: deID)
          .map { geofences in
            geofences.map(apiVisit(fromGeofence:))
          },
        getTrips(auth: t, deviceID: deID)
          .map { trips in
            trips.map(apiVisit(fromTrip:))
          }
      )
    }
    .map { Dictionary(uniqueKeysWithValues: ($0 + $1)) }
    .map(Result.success)
    .catch(Result.failure >>> Just.init(_:))
    .eraseToEffect()
}

func apiVisit(fromGeofence geofence: Geofence) -> (APIVisitID, APIVisit) {
  (
    APIVisitID(rawValue: geofence.id),
    APIVisit(
      centroid: geofence.coordinate,
      createdAt: geofence.createdAt,
      metadata: repackageMetadata(geofence.metadata),
      source: .geofence,
      visited: geofence.visitStatus
    )
  )
}

func apiVisit(fromTrip trip: Trip) -> (APIVisitID, APIVisit) {
  (
    APIVisitID(rawValue: trip.id),
    APIVisit(
      centroid: trip.coordinate,
      createdAt: trip.createdAt,
      metadata: repackageMetadata(trip.metadata),
      source: .geofence,
      visited: trip.visitStatus
    )
  )
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
