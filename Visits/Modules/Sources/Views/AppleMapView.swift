import Foundation
import SwiftUI
import MapKit

public struct AppleMapView: UIViewRepresentable {
  private let coordinate: CLLocationCoordinate2D
  private let span: Double
  private let coordinateRegion: MKCoordinateRegion
  
  public init(coordinate: CLLocationCoordinate2D, span: Double) {
    self.coordinate = coordinate
    self.span = span
    self.coordinateRegion = MKCoordinateRegion(
      center: coordinate,
      latitudinalMeters: span,
      longitudinalMeters: span
    )
  }
  
  public func makeUIView(context: Context) -> MKMapView {
    let mapView = MKMapView()
    mapView.showsUserLocation = false
    mapView.showsCompass = false
    mapView.isRotateEnabled = false
    mapView.isUserInteractionEnabled = false
    
    return mapView
  }

  public func updateUIView(_ mapView: MKMapView, context _: Context) {
    mapView.annotations.forEach{ mapView.removeAnnotation($0) }
    
    let annotation = MKPointAnnotation()
    annotation.coordinate = coordinate
    mapView.addAnnotation(annotation)
    mapView.setRegion(coordinateRegion, animated: false)
  }
  
  public static func dismantleUIView(_ mapView: MKMapView, coordinator: ()) {
    mapView.annotations.forEach{ mapView.removeAnnotation($0) }
  }
}

struct AppleMapView_Previews: PreviewProvider {
  static var previews: some View {
    AppleMapView(
      coordinate: CLLocationCoordinate2D(latitude: 39.754321, longitude: -105.004860),
      span: 150)
      .frame(height: 160)
      .previewLayout(.sizeThatFits)
  }
}
