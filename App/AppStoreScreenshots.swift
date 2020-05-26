import Prelude

import Deliveries
import Delivery
import DriverID
import Location
import Motion

extension AppState {
  public static let deliveriesScreenshot = AppState(
    networkStatus: .online(RequestStatus(deliveriesRequestStatus: false)),
    monitoringReachability: true,
    userStatus: .registered(
      Registered(
        user: User(
          deliveries: [
            DeliveryModel(
              id: "1",
              createdAt: Date(),
              lat: 37.777,
              lng: -122.4164,
              shortAddress: "1301 Market St",
              fullAddress: "Market Square, 1301 Market St, San Francisco, CA  94103, United States",
              metadata: []
            ),
            DeliveryModel(
              id: "2",
              createdAt: Date(),
              lat: 37.777,
              lng: -122.4209,
              shortAddress: "275 Hayes St",
              fullAddress: "275 Hayes St, San Francisco, CA  94102, United States",
              metadata: []
            ),
            DeliveryModel(
              id: "3",
              createdAt: Date(),
              lat: 37.7947633,
              lng: -122.395223,
              shortAddress: "4 Embarcadero Ctr",
              fullAddress: "Embarcadero Plaza, 4 Embarcadero Ctr, San Francisco, CA  94111, United States",
              metadata: []
            )
          ],
          driverID: NonEmptyString(stringLiteral: "id"),
          publishableKey: NonEmptyString(stringLiteral: "PK"),
          trackingStatus: .tracking,
          deliveryNote: "",
          isNoteFieldFocused: false,
          completedDeliveries: ["3"],
          alertContent: .none
        )
      )
    ),
    services: Services(
      location: LocationState(
        monitoring: true,
        permissions: .granted
      ),
      motion: .runtime(.authorized)
    )
  )
  
  public static let deliveryScreenshot = AppState(
    networkStatus: .online(RequestStatus(deliveriesRequestStatus: false)),
    monitoringReachability: true,
    userStatus: .registered(
      Registered(
        user: User(
          deliveries: [],
          driverID: NonEmptyString(stringLiteral: "id"),
          publishableKey: NonEmptyString(stringLiteral: "PK"),
          selectedDelivery: DeliveryModel(
            id: "1",
            createdAt: Date(),
            lat: 37.7947633,
            lng: -122.395223,
            shortAddress: "4 Embarcadero Ctr",
            fullAddress: "Embarcadero Plaza, 4 Embarcadero Ctr, San Francisco, CA  94111, United States",
            metadata: [
              DeliveryModel.Metadata(
                key: "Customer Notes",
                value: "Please deliver before 10 AM"
              ),
              DeliveryModel.Metadata(
                key: "Message",
                value: "Use back door to enter."
              )
            ]
          ),
          trackingStatus: .tracking,
          deliveryNote: "",
          isNoteFieldFocused: false,
          completedDeliveries: ["3"],
          alertContent: .none
        )
      )
    ),
    services: Services(
      location: LocationState(
        monitoring: true,
        permissions: .granted
      ),
      motion: .runtime(.authorized)
    )
  )
  
  public static let checkInScreenshot = AppState(
    networkStatus: .online(RequestStatus(deliveriesRequestStatus: false)),
    monitoringReachability: true,
    userStatus: .authenticated(
      Authenticated(
        publishableKey: "PK",
        registration: .ready(
          .ready(for: "driver@your_business.com")
        )
      )
    ),
    services: Services(
      location: LocationState(
        monitoring: true,
        permissions: .granted
      ),
      motion: .runtime(.authorized)
    )
  )
}
