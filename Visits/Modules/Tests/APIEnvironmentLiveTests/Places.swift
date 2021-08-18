import Utility
import XCTest
import Types
@testable import APIEnvironmentLive

final class APIEnvironmentLivePlacesTests: XCTestCase {
  func testGeofencesNotInNearbyEmptyWithNoSummary() throws {
    XCTAssertEqual(
      geofencesNotInNearby(nearbyGeofences: [geofence1], summary: summary0),
      []
    )
  }

  func testGeofencesNotInNearbyEmptyWithNoSummaryAndGeofences() throws {
    XCTAssertEqual(
      geofencesNotInNearby(nearbyGeofences: [], summary: summary0),
      []
    )
  }

  func testGeofencesNotInNearbyEmptyWithFullOverlap() throws {
    XCTAssertEqual(
      geofencesNotInNearby(nearbyGeofences: [geofence1, geofence2, geofence3], summary: summary123),
      []
    )
  }

  func testGeofencesNotInNearbyFullWithFullOverlap() throws {
    XCTAssertEqual(
      geofencesNotInNearby(nearbyGeofences: [geofence4], summary: summary123),
      ["1", "2", "3"]
    )
  }

  func testGeofencesNotInNearbyPartialWithPartialOverlap() throws {
    XCTAssertEqual(
      geofencesNotInNearby(nearbyGeofences: [geofence1], summary: summary123),
      ["2", "3"]
    )
  }

}

let geofence1 = Geofence(
  id: "1",
  deviceID: "D1",
  address: "",
  createdAt: Date(),
  metadata: nil,
  shape: .circle(.init(center: .init(latitude: 37.783049, longitude: -122.418242)!, radius: 100)),
  markers: []
)

let geofence2 = Geofence(
  id: "2",
  deviceID: "D1",
  address: "",
  createdAt: Date(),
  metadata: nil,
  shape: .circle(.init(center: .init(latitude: 37.783049, longitude: -122.418242)!, radius: 100)),
  markers: []
)

let geofence3 = Geofence(
  id: "3",
  deviceID: "D1",
  address: "",
  createdAt: Date(),
  metadata: nil,
  shape: .circle(.init(center: .init(latitude: 37.783049, longitude: -122.418242)!, radius: 100)),
  markers: []
)

let geofence4 = Geofence(
  id: "4",
  deviceID: "D1",
  address: "",
  createdAt: Date(),
  metadata: nil,
  shape: .circle(.init(center: .init(latitude: 37.783049, longitude: -122.418242)!, radius: 100)),
  markers: []
)

let marker1 = GeofenceMarker(
  id: "123",
  geofenceID: "1",
  visitStatus: .visited(Date(), Date()),
  routeTo: nil
)

let marker2 = GeofenceMarker(
  id: "456",
  geofenceID: "2",
  visitStatus: .visited(Date(), Date()),
  routeTo: nil
)

let marker3 = GeofenceMarker(
  id: "789",
  geofenceID: "3",
  visitStatus: .visited(Date(), Date()),
  routeTo: nil
)

let summary0 = VisitSummary(
  days: [
    nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
  ]
)

let summary1 = VisitSummary(
  days: [
    .init(driveDistance: 100, geofenceMarkers: .init(rawValue: [marker1])!),
    nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil, nil
  ]
)

let summary123 = VisitSummary(
  days: [
    .init(driveDistance: 100, geofenceMarkers: .init(rawValue: [marker1])!),
    .init(driveDistance: 100, geofenceMarkers: .init(rawValue: [marker2])!),
    .init(driveDistance: 100, geofenceMarkers: .init(rawValue: [marker3])!),
    nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil
  ]
)
