import ComposableArchitecture
import LogEnvironment
import MapEnvironment
import MapKit
import Prelude
import Types


public extension MapEnvironment {
  static let live = Self(
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
        if let address = addressString(from: address) {
          mapItem.name = address
        }
        mapItem.openInMaps(launchOptions: options)
      }
    }
  )
}

func addressString(from a: Either<FullAddress, Street>?) -> String? {
  switch a {
  case .none: return nil
  case let .some(.left(full)): return full.string
  case let .some(.right(street)): return street.string
  }
}
