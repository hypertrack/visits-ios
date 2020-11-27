import Coordinate
import DeviceID
import DriverID
import Foundation
import NonEmpty
import PublishableKey
import SDK
import Visit


extension AppState {
  public static let visitsScreenshot = Self(
    network: .online,
    flow: .visits(
      .mixed(
        [
          .right(
            AssignedVisit(
              id: AssignedVisit.ID(rawValue: "ID1"),
              createdAt: Date(),
              source: .geofence,
              location: Coordinate(latitude: 37.776495, longitude: -122.416857)!,
              geotagSent: .checkedOut(Date()),
              noteFieldFocused: false,
              address: .both(
                AssignedVisit.Street(rawValue: "1301 Market St"),
                AssignedVisit.FullAddress(rawValue: "Market Square, 1301 Market St, San Francisco, CA  94103, United States")
              )
            )
          ),
          .right(
            AssignedVisit(
              id: AssignedVisit.ID(rawValue: "ID2"),
              createdAt: Date(),
              source: .geofence,
              location: Coordinate(latitude: 37.777004, longitude: -122.420884)!,
              geotagSent: .checkedIn,
              noteFieldFocused: false,
              address: .both(
                AssignedVisit.Street(rawValue: "275 Hayes St"),
                AssignedVisit.FullAddress(rawValue: "275 Hayes St, San Francisco, CA  94102, United States")
              )
            )
          ),
          .right(
            AssignedVisit(
              id: AssignedVisit.ID(rawValue: "ID3"),
              createdAt: Date(),
              source: .geofence,
              location: Coordinate(latitude: 37.795076, longitude: -122.396241)!,
              geotagSent: .notSent,
              noteFieldFocused: false,
              address: .both(
                AssignedVisit.Street(rawValue: "4 Embarcadero Ctr"),
                AssignedVisit.FullAddress(rawValue: "Embarcadero Plaza, 4 Embarcadero Ctr, San Francisco, CA  94111, United States")
              )
            )
          )
        ]
      ),
      nil,
      PublishableKey(rawValue: "Key"),
      DriverID(rawValue: "ID"),
      DeviceID(rawValue: "ID"),
      .running,
      Permissions(
        locationAccuracy: .full,
        locationPermissions: .authorized,
        motionPermissions: .authorized
      ),
      nil,
      nil
    )
  )
  
  public static let visitScreenshot = Self(
    network: .online,
    flow: .visits(
      .selectedAssigned(
        AssignedVisit(
          id: AssignedVisit.ID(rawValue: "ID3"),
          createdAt: Date(),
          source: .geofence,
          location: Coordinate(latitude: 37.7947633, longitude: -122.395223)!,
          geotagSent: .notSent,
          noteFieldFocused: false,
          address: .both(
            AssignedVisit.Street(rawValue: "4 Embarcadero Ctr"),
            AssignedVisit.FullAddress(rawValue: "Embarcadero Plaza, 4 Embarcadero Ctr, San Francisco, CA  94111, United States")
          ),
          metadata: NonEmptyDictionary(
            rawValue: [
              AssignedVisit.Name(rawValue: "Customer Notes"): AssignedVisit.Contents(rawValue: "Please deliver before 10 AM"),
              AssignedVisit.Name(rawValue: "Message"): AssignedVisit.Contents(rawValue: "Use back door to enter.")
            ]
          )
        ),
        []
      ),
      nil,
      PublishableKey(rawValue: "Key"),
      DriverID(rawValue: "ID"),
      DeviceID(rawValue: "ID"),
      .running,
      Permissions(
        locationAccuracy: .full,
        locationPermissions: .authorized,
        motionPermissions: .authorized
      ),
      nil,
      nil
    )
  )
}

