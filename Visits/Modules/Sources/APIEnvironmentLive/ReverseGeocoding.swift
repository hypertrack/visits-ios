import Combine
import ComposableArchitecture
import Contacts
import CoreLocation
import NonEmpty
import Prelude
import Types


func reverseGeocode(_ coordinates: [Coordinate]) -> Effect<[(Coordinate, These<Order.Street, Order.FullAddress>?)], Never> {
  coordinates.publisher
    .flatMap { reverseGeocodeCoordinate($0) }
    .collect()
    .eraseToEffect()
}


func reverseGeocodeCoordinate(_ coordinate: Coordinate) -> AnyPublisher<(Coordinate, These<Order.Street, Order.FullAddress>?), Never> {
  Future { promise in
    reverseGeocodeLocation(coordinate) {
      if let address = $0 {
        promise(.success((coordinate, address)))
      } else {
        promise(.success((coordinate, nil)))
      }
    }
  }
  .eraseToAnyPublisher()
}

func reverseGeocodeLocation(_ coordinate: Coordinate, completion: @escaping (These<Order.Street, Order.FullAddress>?) -> Void) {
  let locaiton = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
  CLGeocoder().reverseGeocodeLocation(locaiton) { placemarks, error in
    guard error == nil, let first = placemarks?.first else {
      completion(nil)
      return
    }
    completion(
      constructAddress(
        fromSubThoroughfare: first.subThoroughfare,
        thoroughfare: first.thoroughfare,
        formattedAddress: first.formattedAddress
      )
    )
  }
}

func constructAddress(
  fromSubThoroughfare subThoroughfare: String?,
  thoroughfare: String?,
  formattedAddress: String?
) -> These<Order.Street, Order.FullAddress>? {
  let streetString: String? = { streetNumber in { streetName in "\(streetNumber) \(streetName)" } }
    <!> subThoroughfare
    <*> thoroughfare
    <|> thoroughfare
  let fullAddressString = formattedAddress
  
  
  let street = streetString
    >>- NonEmptyString.init(rawValue:)
    <¡> Order.Street.init(rawValue:)
  
  let fullAddress = fullAddressString
    >>- NonEmptyString.init(rawValue:)
    <¡> Order.FullAddress.init(rawValue:)
  
  return maybeThese(street)(fullAddress)
}

extension CLPlacemark {
  var formattedAddress: String? {
    guard let postalAddress = postalAddress else { return nil }
    return CNPostalAddressFormatter.string(
      from: postalAddress,
      style: .mailingAddress
    ).replacingOccurrences(of: "\n", with: " ")
  }
}
