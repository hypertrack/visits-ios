import Combine
import ComposableArchitecture
import Contacts
import CoreLocation
import LogEnvironment
import MapKit
import NonEmpty
import OrderedCollections
import Utility
import Types


func reverseGeocode(_ coordinate: Coordinate) -> Effect<GeocodedResult, Never> {
  .future { callback in
    let locaiton = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    geocoder.cancelGeocode()
    geocoder.reverseGeocodeLocation(locaiton) { placemarks, error in
      guard error == nil, let first = placemarks?.first else {
        callback(.success(.init(coordinate: coordinate, address: .none)))
        return
      }
      callback(
        .success(
          .init(
            coordinate: coordinate,
            address: constructAddress(
              fromSubThoroughfare: first.subThoroughfare,
              thoroughfare: first.thoroughfare,
              formattedAddress: first.formattedAddress
            )
          )
        )
      )
    }
  }
}

func subscribeToCompletionResults() -> Effect<[LocalSearchCompletion], Never> {
  .run { subscriber in
    logEffect("subscribeToLocalSearchCompletionResults")
    
    searchCompleterDelegate = MKLocalSearchCompleterClientDelegate {
      subscriber.send((searchCompleter.results.compactMap(toLocalSearchCompletion) |> OrderedSet.init(_:)).elements)
    }
    searchCompleter.delegate = searchCompleterDelegate
    
    return AnyCancellable {
      searchCompleterDelegate = nil
    }
  }
}

func autocompleteLocalSearch(_ search: AddressSearch?, _ around: Coordinate) -> Effect<Never, Never> {
  .fireAndForget {
    guard let search = search else {
      if searchCompleter.isSearching {
        searchCompleter.cancel()
      }
      return
    }
    
    searchCompleter.pointOfInterestFilter = .includingAll
    searchCompleter.resultTypes = [.address, .pointOfInterest]
    searchCompleter.region = region(for: around)
    searchCompleter.queryFragment = search.string
  }
}

func localSearch(_ completion: LocalSearchCompletion, _ around: Coordinate) -> Effect<LocalSearchResult, Never> {
  .future { callback in
    if let strongLocalSearch = localSearch {
      strongLocalSearch.cancel()
      localSearch = nil
    }
    
    let request: MKLocalSearch.Request
    if let completion = searchCompleter.results.first(where: { c in
      if let subtitle = completion.subtitle, subtitle.string != "Search Nearby" {
        if c.subtitle == subtitle.string {
          return true
        }
      }
      return completion.title.string == c.title
    }) {
      request = .init(completion: completion)
    } else {
      request = .init()
      request.naturalLanguageQuery = completion.subtitle?.string ?? completion.title.string
    }
    
    request.region = region(for: around)
    request.resultTypes = [.address, .pointOfInterest]
    request.pointOfInterestFilter = .includingAll
    
    let ls = MKLocalSearch(request: request)
    localSearch = ls
    
    ls.start { response, error in
      let error = error?.localizedDescription
      let errorNEString = error.flatMap(NonEmptyString.init(rawValue:))
      
      let responseItems = response?.mapItems
      
      switch (responseItems, errorNEString) {
      case      (.none, .none):
        callback(.success(.fatalError))
      case let  (.none, .some(error)):
        callback(.success(.error(.init(rawValue: error))))
      case let  (.some(r), _):
        let items = r.compactMap { item in
          item.placemark.coordinate >>- Coordinate.init(coordinate2D:) <¡> { c in
            MapPlace(
              name: item.name >>- NonEmptyString.init(rawValue:) <¡> MapPlace.Name.init(rawValue:),
              address: (item.placemark.formattedAddress <¡> Address.init(string:)) ?? .none,
              location: c
            )
          }
        }
        
        if let naItems = NonEmptyArray(items) {
          if let fullMatch = naItems.first(where: { mp in
            mp.address.fullAddress?.string == completion.subtitle?.string
          }) {
            callback(.success(.result(fullMatch)))
          } else {
            let first = naItems.first
            if let more = NonEmptyArray(naItems.dropFirst()) {
              callback(.success(.results(first, more)))
            } else {
              callback(.success(.result(first)))
            }
          }
        } else {
          callback(.success(.empty))
        }
      }
    }
  }
}


private func toLocalSearchCompletion(_ completion: MKLocalSearchCompletion) -> LocalSearchCompletion? {
  NonEmptyString(rawValue: completion.title)
    <¡> { title in
      LocalSearchCompletion(
        title: .init(rawValue: title),
        subtitle: NonEmptyString(rawValue: completion.subtitle)
          <¡> LocalSearchCompletion.Subtitle.init(rawValue:)
      )
    }
}

private func region(for coordinate: Coordinate) -> MKCoordinateRegion {
  .init(center: coordinate.coordinate2D, latitudinalMeters: radiusM, longitudinalMeters: radiusM)
}

private let geocoder = CLGeocoder()
private let searchCompleter = MKLocalSearchCompleter()
private var searchCompleterDelegate: MKLocalSearchCompleterClientDelegate?
private var localSearch: MKLocalSearch?

private let radiusKM: CLLocationDistance = 500
private let radiusM = radiusKM * 1_000


private class MKLocalSearchCompleterClientDelegate: NSObject, MKLocalSearchCompleterDelegate {
  let completerDidUpdateResults: () -> Void
  
  init(completerDidUpdateResults: @escaping () -> Void) {
    self.completerDidUpdateResults = completerDidUpdateResults
  }
  
  func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
    completerDidUpdateResults()
  }
  
  func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
    completerDidUpdateResults()
  }
}

private func constructAddress(
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

private extension CLPlacemark {
  var formattedAddress: String? {
    guard let postalAddress = postalAddress else { return nil }
    return CNPostalAddressFormatter.string(
      from: postalAddress,
      style: .mailingAddress
    ).replacingOccurrences(of: "\n", with: " ")
  }
}
