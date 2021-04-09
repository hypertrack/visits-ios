import APIEnvironment
import Combine
import ComposableArchitecture
import Contacts
import CoreLocation
import NonEmpty
import Prelude
import Types


func reverseGeocode(_ coordinate: Coordinate) -> Effect<Address, Never> {
  .future { callback in
    let locaiton = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    CLGeocoder().reverseGeocodeLocation(locaiton) { placemarks, error in
      guard error == nil, let first = placemarks?.first else {
        callback(.success(.none))
        return
      }
      callback(
        .success(
          constructAddress(
            fromSubThoroughfare: first.subThoroughfare,
            thoroughfare: first.thoroughfare,
            formattedAddress: first.formattedAddress
          )
        )
      )
    }
  }
}

func constructAddress(
  fromSubThoroughfare subThoroughfare: String?,
  thoroughfare: String?,
  formattedAddress: String?
) -> Address {
  let streetString: String? = { streetNumber in { streetName in "\(streetNumber) \(streetName)" } }
    <!> subThoroughfare
    <*> thoroughfare
    <|> thoroughfare
  let fullAddressString = formattedAddress
  
  let street = streetString
    >>- NonEmptyString.init(rawValue:)
    <¡> Street.init(rawValue:)
  
  let fullAddress = fullAddressString
    >>- NonEmptyString.init(rawValue:)
    <¡> FullAddress.init(rawValue:)
  
  return .init(street: street, fullAddress: fullAddress)
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
