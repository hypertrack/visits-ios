import ComposableArchitecture
import LogEnvironment
import MapDependency
import MapKit
import Utility
import Types


public extension MapDependency {
  static let live = Self(
    autocompleteLocalSearch: autocompleteLocalSearch(_:_:),
    localSearch: localSearch(_:_:),
    openMap: { coordinate, address in
      .fireAndForget {
        logEffect("openMap")
        let region = MKCoordinateRegion(
          center: coordinate.coordinate2D,
          span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.02)
        )
        let placemark = MKPlacemark(coordinate: coordinate.coordinate2D)
        let mapItem = MKMapItem(placemark: placemark)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: region.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: region.span)
        ]
        if let address = address.street?.string ?? address.fullAddress?.string {
          mapItem.name = address
        }
        mapItem.openInMaps(launchOptions: options)
      }
    },
    reverseGeocode: reverseGeocode(_:),
    subscribeToLocalSearchCompletionResults: subscribeToCompletionResults
  )
}
