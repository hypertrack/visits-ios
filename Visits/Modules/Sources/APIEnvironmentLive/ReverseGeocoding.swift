import Combine
import ComposableArchitecture
import Contacts
import Coordinate
import CoreLocation
import NonEmpty
import Prelude
import Visit


public func reverseGeocode(_ coordinates: [Coordinate]) -> Effect<[(Coordinate, These<AssignedVisit.Street, AssignedVisit.FullAddress>?)], Never> {
  coordinates.publisher
    .flatMap { reverseGeocodeCoordinate($0) }
    .collect()
    .eraseToEffect()
}


func reverseGeocodeCoordinate(_ coordinate: Coordinate) -> AnyPublisher<(Coordinate, These<AssignedVisit.Street, AssignedVisit.FullAddress>?), Never> {
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

func reverseGeocodeLocation(_ coordinate: Coordinate, completion: @escaping (These<AssignedVisit.Street, AssignedVisit.FullAddress>?) -> Void) {
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
) -> These<AssignedVisit.Street, AssignedVisit.FullAddress>? {
  let streetString: String? = { streetNumber in { streetName in "\(streetNumber) \(streetName)" } }
    <!> subThoroughfare
    <*> thoroughfare
    <|> thoroughfare
  let fullAddressString = formattedAddress
  
  
  let street = streetString
    >>- NonEmptyString.init(rawValue:)
    <¡> AssignedVisit.Street.init(rawValue:)
  
  let fullAddress = fullAddressString
    >>- NonEmptyString.init(rawValue:)
    <¡> AssignedVisit.FullAddress.init(rawValue:)
  
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
