import Foundation
import NonEmpty
import Tagged
import Types
import Utility
import IdentifiedCollections


extension AppState {
  static let ordersScreenshot = Self.operational(
    operational_ |> \.flow *< .main(
      main |> \.trip *< .some(trip)
           <> \.tab *< .orders
    )
  )
  
  static let orderScreenshot = Self.operational(
    operational_ |> \.flow *< .main(
      main |> \.selectedOrderId *< .some(ongoing.id)
           <> \.trip *< .some(trip)
           <> \.tab *< .orders
    )
  )
  
  static let placesScreenshot = Self.operational(
    operational_ |> \.flow *< .main(
      main |> \.places *< .some(placesSummary)
           <> \.history *< history
           <> \.tab *< .places
    )
  )

  static let placeScreenshot = Self.operational(
    operational_ |> \.flow *< .main(
      main |> \.selectedPlace *< .some(cityHall)
           <> \.tab *< .places
    )
  )

  static let createPlaceChoosingCoordinateScreenshot = Self.operational(
    operational_ |> \.flow *< .main(
      main |> \.addPlace *< .init(
        flow: .choosingCoordinate(
          .init(
            coordinate: artsCenterCoordinate,
            address: artsCenterAddress
          )
        ),
        entities: []
      )
    )
  )

  static let createPlaceEditingMetadataScreenshot = Self.operational(
    operational_ |> \.flow *< .main(
      main |> \.addPlace *< .init(
        flow: .editingMetadata(
          .init(
            flow: .editing(.init(id: .init(rawValue: "1"), name: .init(rawValue: "Arts Center"))),
            center: .init(rawValue: artsCenterCoordinate),
            customAddress: nil,
            radius: .hundred,
            description: nil
          )
        ),
        entities: []
      )
    )
  )

  static let visitsScreenshot = Self.operational(
    operational_ |> \.flow *< .main(
      main |> \.places *< .some(placesSummary)
           <> \.placesPresentation *< .byVisit
           <> \.history *< .some(history)
           <> \.tab *< .places
    )
  )
  
  static let mapScreenshot = Self.operational(
    operational_ |> \.flow *< .main(
      main |> \.trip *< .some(trip)
           <> \.history *< history
           <> \.tab *< .map
    )
  )

  static let profileScreenshot = Self.operational(
    operational_ |> \.flow *< .main(
      main |> \.tab *< .profile
    )
  )
}

private let history = History(
  coordinates: [
    Coordinate(latitude: 37.76477793772538, longitude: -122.41957068443297)!,
    Coordinate(latitude: 37.76477793772538, longitude: -122.4196484684944)!,
    Coordinate(latitude: 37.77180875405714, longitude: -122.42035388946533)!,
    Coordinate(latitude: 37.7730130005326, longitude: -122.42180228233337)!,
    Coordinate(latitude: 37.773962814902774, longitude: -122.42069721221922)!,
    Coordinate(latitude: 37.776659542769934, longitude: -122.42124438285828)!,
    Coordinate(latitude: 37.77676978426915, longitude: -122.42056846618652)!,
    Coordinate(latitude: 37.77657474150483, longitude: -122.42050409317015)!,
    Coordinate(latitude: 37.77662562227558, longitude: -122.42010712623598)!,
    Coordinate(latitude: 37.77690546588866, longitude: -122.42021441459654)!,
    Coordinate(latitude: 37.77686306540933, longitude: -122.42057919502257)!,
    Coordinate(latitude: 37.77676978426915, longitude: -122.4204933643341)!,
    Coordinate(latitude: 37.77671890359764, longitude: -122.42127656936647)!,
    Coordinate(latitude: 37.77894914015784, longitude: -122.42174863815306)!,
    Coordinate(latitude: 37.77886434151916, longitude: -122.42224216461183)!,
    Coordinate(latitude: 37.77883042203647, longitude: -122.4221885204315)!,
    Coordinate(latitude: 37.77883042203647, longitude: -122.42229580879211)!,
    Coordinate(latitude: 37.779000019294344, longitude: -122.42170572280882)!,
    Coordinate(latitude: 37.77989039851448, longitude: -122.42190957069396)!,
    Coordinate(latitude: 37.780085432530804, longitude: -122.42036461830139)!,
    Coordinate(latitude: 37.774929577713245, longitude: -122.41936683654784)!,
    Coordinate(latitude: 37.77681218480201, longitude: -122.41704940795898)!,
    Coordinate(latitude: 37.77671890359764, longitude: -122.41700649261476)!,
    Coordinate(latitude: 37.77682066490566, longitude: -122.41694211959839)!,
    Coordinate(latitude: 37.77686306540933, longitude: -122.41694211959839)!,
    Coordinate(latitude: 37.77739730967186, longitude: -122.41634130477905)!,
    Coordinate(latitude: 37.78331613854221, longitude: -122.41753220558167)!,
    Coordinate(latitude: 37.78321438617593, longitude: -122.41843342781067)!,
    Coordinate(latitude: 37.78309567490489, longitude: -122.41842806339264)!,
    Coordinate(latitude: 37.783019360415665, longitude: -122.4183851480484)!,
    Coordinate(latitude: 37.78315503056424, longitude: -122.41850852966309)!
  ]
)

private let ongoing = Order(
  id: Order.ID(rawValue: "ID4"),
  createdAt: Calendar.current.date(bySettingHour: 9, minute: 37, second: 0, of: Date())!,
  location: Coordinate(latitude: 37.780592, longitude: -122.413322)!,
  address: .init(
    street: Street(rawValue: "87 McAllister St"),
    fullAddress: FullAddress(rawValue: "87 McAllister St, San Francisco, CA  94102, United States")
  ),
  status: .ongoing(.unfocused),
  note: nil,
  visited: nil,
  metadata: [
    "Customer Notes": "Please deliver before 10 AM",
    "Message": "Use back door to enter."
  ]
)

private let visited = Order(
  id: Order.ID(rawValue: "ID7"),
  createdAt: Calendar.current.date(bySettingHour: 9, minute: 40, second: 0, of: Date())!,
  location: Coordinate(latitude: 37.778655, longitude: -122.422231)!,
  address: .init(
    street: Street(rawValue: "333 Fulton St"),
    fullAddress: FullAddress(rawValue: "333 Fulton St, San Francisco, CA  94102, United States")
  ),
  status: .ongoing(.unfocused),
  note: nil,
  visited: .entered(Date())
)

private let completed = Order(
  id: Order.ID(rawValue: "ID1"),
  createdAt: Calendar.current.date(bySettingHour: 9, minute: 35, second: 0, of: Date())!,
  location: Coordinate(latitude: 37.776692, longitude: -122.416557)!,
  address: .init(
    street: Street(rawValue: "1301 Market St"),
    fullAddress: FullAddress(rawValue: "Market Square, 1301 Market St, San Francisco, CA  94103, United States")
  ),
  status: .completed(Date()),
  note: nil,
  visited: .entered(Date())
)

private let snoozed = Order(
  id: Order.ID(rawValue: "ID2"),
  createdAt: Calendar.current.date(bySettingHour: 9, minute: 36, second: 0, of: Date())!,
  location: Coordinate(latitude: 37.776753, longitude: -122.420371)!,
  address: .init(
    street: Street(rawValue: "275 Hayes St"),
    fullAddress: FullAddress(rawValue: "275 Hayes St, San Francisco, CA  94102, United States")
  ),
  status: .snoozed,
  note: nil,
  visited: .entered(Date())
)

private let canceled = Order(
  id: Order.ID(rawValue: "ID6"),
  createdAt: Calendar.current.date(bySettingHour: 9, minute: 38, second: 0, of: Date())!,
  location: Coordinate(latitude: 37.783049, longitude: -122.418242)!,
  address: .init(
    street: Street(rawValue: "601 Eddy St"),
    fullAddress: FullAddress(rawValue: "601 Eddy St, San Francisco, CA  94109, United States")
  ),
  status: .cancelled,
  note: nil,
  visited: .entered(Date())
)

private let orders = IdentifiedArrayOf<Order>(
  uniqueElements: [
    visited,
    ongoing,
    completed,
    snoozed,
    canceled
  ]
)

private let trip = Trip(
  id: "SADFQSF123",
  createdAt: Calendar.current.date(bySettingHour: 9, minute: 38, second: 0, of: Date())!,
  status: .active, orders: orders.elements,
  metadata: ["Name": "VIP Delivery"]
)

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

private let artsCenter = Place(
  id: "2",
  address: artsCenterAddress,
  createdAt: .init(rawValue: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!),
  currentlyInside: nil,
  metadata: ["name":"Arts Center"],
  shape: .circle(.init(center: artsCenterCoordinate, radius: 100)),
  visits: [
    .init(
      id: "123456",
      entry: .init(rawValue: date(hour: 8, minute: 05, second: 30)),
      exit: .init(rawValue: date(hour: 8, minute: 30, second: 30)),
      route: .init(
        distance: .init(rawValue: 1234),
        duration: .init(rawValue: 1234),
        idleTime: .init(rawValue: 123)
      )
    )
  ]
)

private let artsCenterCoordinate = Coordinate(latitude: 37.785713, longitude: -122.402123)!
private let artsCenterAddress = Address(street: "Yerba Buena Center for the Arts", fullAddress: "Yerba Buena Center for the Arts, 701 Mission St, San Francisco, CA  94103, United States")

private let placesSummary = PlacesSummary(
  places: [cityHall, artsCenter],
  requestedAt: Date(),
  driveDistancesForDaysWithVisits: NonEmptyArray(rawValue: [UInt?](repeating: 12345, count: 60))!
)

private let publishableKey = PublishableKey(rawValue: "Key")
private let deviceID = DeviceID(rawValue: "UNIQUE-ID")

private func date(hour: Int, minute: Int, second: Int) -> Date {
  Calendar.current.date(bySettingHour: hour, minute: minute, second: second, of: Date())!
}

private func taggedDate<Tag>(hour: Int, minute: Int, second: Int) -> Tagged<Tag, Date> {
  .init(rawValue: date(hour: hour, minute: minute, second: second))
}

private let operational_ = OperationalState(
  experience: .regular,
  flow: .firstRun,
  locationAlways: .requestedAfterWhenInUse,
  pushStatus: .dialogSplash(.shown),
  sdk: .init(status: .unlocked(deviceID, .running)),
  version: "1.2.3 (45)",
  visibility: .onScreen
)

private let main = MainState(
  map: .initialState,
  trip: nil,
  places: nil,
  tab: .orders,
  publishableKey: publishableKey,
  profile: .init(name: "User", metadata: ["email": "user@company.com"]),
  integrationStatus: .integrated(.notRefreshing),
  visitsDateFrom: Date(),
  visitsDateTo: Date(),
  workerHandle: WorkerHandle("eugene@hypertrack.io")
)
