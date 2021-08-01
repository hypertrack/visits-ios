import MapKit
import SwiftUI
import Views


private let pinShadowViewDiameter: CGFloat = 5

struct PlaceMapView: UIViewRepresentable {
  @Binding var inputCoordinateForSearch: CLLocationCoordinate2D?

  private let pinView = UIImageView(image: UIImage(systemName: "mappin", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .medium, scale: .default)))
  
  private let pinShadowView = UIView()

  func makeUIView(context: Context) -> MKMapView {
    let mapView = MKMapView()
    mapView.delegate = context.coordinator
    mapView.showsUserLocation = true
    mapView.showsCompass = false
    mapView.isRotateEnabled = false

    pinView.tintColor = UIColor.black
    pinView.translatesAutoresizingMaskIntoConstraints = false
    pinShadowView.translatesAutoresizingMaskIntoConstraints = false

    mapView.addSubview(pinShadowView)
    mapView.addSubview(pinView)

    pinShadowView.layer.cornerRadius = pinShadowViewDiameter / 2
    pinShadowView.clipsToBounds = false
    pinShadowView.backgroundColor = UIColor.green

    pinView.centerXAnchor.constraint(equalTo: mapView.centerXAnchor).isActive = true
    pinView.centerYAnchor.constraint(
      equalTo: mapView.centerYAnchor,
      constant: (-pinView.frame.height / 2) + 4
    ).isActive = true

    pinShadowView.centerXAnchor.constraint(equalTo: mapView.centerXAnchor).isActive = true
    pinShadowView.centerYAnchor.constraint(equalTo: mapView.centerYAnchor).isActive = true
    pinShadowView.widthAnchor.constraint(equalToConstant: pinShadowViewDiameter).isActive = true
    pinShadowView.heightAnchor.constraint(
      equalToConstant: pinShadowViewDiameter
    ).isActive = true

    return mapView
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  func updateUIView(_ uiView: MKMapView, context _: Context) {}

  class Coordinator: NSObject, MKMapViewDelegate {
    var control: PlaceMapView
    var isAutoZoomEnabled = true

    init(_ control: PlaceMapView) {
      self.control = control
    }

    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
      control.isZoomNeeded(mapView, userLocation, isAutoZoomEnabled)
      isAutoZoomEnabled = false
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
      control.inputCoordinateForSearch = mapView.centerCoordinate

      if !animated {
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut, animations: {
          self.control.pinView.frame.origin.y += self.control.pinView.frame.height / 2
        }, completion: nil)
      }
    }

    func mapView(_: MKMapView, regionWillChangeAnimated animated: Bool) {
      if !animated {
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut, animations: {
          self.control.pinView.frame.origin.y -= self.control.pinView.frame.height / 2
        }, completion: nil)
      }
    }
  }

  private func isZoomNeeded(
    _ mapView: MKMapView,
    _ userLocation: MKUserLocation,
    _ isAutoZoomEnabled: Bool
  ) {
    if userLocation.coordinate.latitude != -180,
      userLocation.coordinate.longitude != -180 {
      if isAutoZoomEnabled {
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(
          center: userLocation.coordinate,
          span: span
        )
        mapView.setRegion(region, animated: false)
      }
    }
  }
}

