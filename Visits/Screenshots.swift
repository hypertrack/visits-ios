import Foundation
import Prelude
import Types


extension AppState {
  static let ordersScreenshot = Self.operational(
    operational_ |> \.flow *< .main(
      main |> \.orders *< orders
           <> \.tab *< .orders
    )
  )
  
  static let orderScreenshot = Self.operational(
    operational_ |> \.flow *< .main(
      main |> \.selectedOrder *< .some(notSent)
           <> \.tab *< .orders
    )
  )
  
  static let mapScreenshot = Self.operational(
    operational_ |> \.flow *< .main(
      main |> \.orders *< orders
           <> \.history *< History(
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
           <> \.tab *< .map
    )
  )
  
  static let summaryScreenshot = Self.operational(
    operational_ |> \.flow *< .main(
      main |> \.history *< .some(
                             History(
                               coordinates: [],
                               trackedDuration: 20100,
                               driveDistance: 16898,
                               driveDuration: 11100,
                               walkSteps: 2345,
                               walkDuration: 2100,
                               stopDuration: 6900
                             )
                           )
           <> \.tab *< .summary
    )
  )
  
  static let profileScreenshot = Self.operational(
    operational_ |> \.flow *< .main(
      main |> \.tab *< .profile
    )
  )
}


private let notSent = Order(
  id: Order.ID(rawValue: "ID4"),
  createdAt: Calendar.current.date(bySettingHour: 9, minute: 37, second: 0, of: Date())!,
  source: .trip,
  location: Coordinate(latitude: 37.780592, longitude: -122.413322)!,
  geotagSent: .pickedUp,
  noteFieldFocused: false,
  address: .init(
    street: Street(rawValue: "87 McAllister St"),
    fullAddress: FullAddress(rawValue: "87 McAllister St, San Francisco, CA  94102, United States")
  ),
  metadata: [
    "Customer Notes": "Please deliver before 10 AM",
    "Message": "Use back door to enter."
  ]
)

private let entered = Order(
  id: Order.ID(rawValue: "ID7"),
  createdAt: Calendar.current.date(bySettingHour: 9, minute: 40, second: 0, of: Date())!,
  source: .trip,
  location: Coordinate(latitude: 37.778655, longitude: -122.422231)!,
  geotagSent: .entered(Date()),
  noteFieldFocused: false,
  address: .init(
    street: Street(rawValue: "333 Fulton St"),
    fullAddress: FullAddress(rawValue: "333 Fulton St, San Francisco, CA  94102, United States")
  )
)

private let checkedOut1 = Order(
  id: Order.ID(rawValue: "ID1"),
  createdAt: Calendar.current.date(bySettingHour: 9, minute: 35, second: 0, of: Date())!,
  source: .trip,
  location: Coordinate(latitude: 37.776692, longitude: -122.416557)!,
  geotagSent: .checkedOut(.none, Date()),
  noteFieldFocused: false,
  address: .init(
    street: Street(rawValue: "1301 Market St"),
    fullAddress: FullAddress(rawValue: "Market Square, 1301 Market St, San Francisco, CA  94103, United States")
  )
)

private let checkedOut2 = Order(
  id: Order.ID(rawValue: "ID2"),
  createdAt: Calendar.current.date(bySettingHour: 9, minute: 36, second: 0, of: Date())!,
  source: .trip,
  location: Coordinate(latitude: 37.776753, longitude: -122.420371)!,
  geotagSent: .checkedOut(.none, Date()),
  noteFieldFocused: false,
  address: .init(
    street: Street(rawValue: "275 Hayes St"),
    fullAddress: FullAddress(rawValue: "275 Hayes St, San Francisco, CA  94102, United States")
  )
)

private let checkedOut3 = Order(
  id: Order.ID(rawValue: "ID5"),
  createdAt: Calendar.current.date(bySettingHour: 9, minute: 38, second: 0, of: Date())!,
  source: .trip,
  location: Coordinate(latitude: 37.783049, longitude: -122.418242)!,
  geotagSent: .checkedOut(.none, Date()),
  noteFieldFocused: false,
  address: .init(
    street: Street(rawValue: "601 Eddy St"),
    fullAddress: FullAddress(rawValue: "601 Eddy St, San Francisco, CA  94109, United States")
  )
)

private let orders: Set<Order> = [notSent, entered, checkedOut1, checkedOut2, checkedOut3]

private let publishableKey = PublishableKey(rawValue: "Key")
private let deviceID = DeviceID(rawValue: "UNIQUE-ID")
private let driverID = DriverID(rawValue: "user@company.com")
private let permissions = Permissions(
  locationAccuracy: .full,
  locationPermissions: .authorizedAlways,
  motionPermissions: .authorized
)

private let operational_ = OperationalState(
  experience: .regular,
  flow: .firstRun,
  locationAlways: .requestedAfterWhenInUse,
  pushStatus: .dialogSplash(.shown),
  sdk: .init(permissions: .granted, status: .unlocked(deviceID, .running)),
  version: "1.2.3 (45)"
)

private let main = MainState(
  orders: [],
  places: [],
  tab: .orders,
  publishableKey: publishableKey,
  driverID: driverID,
  refreshing: .none
)
