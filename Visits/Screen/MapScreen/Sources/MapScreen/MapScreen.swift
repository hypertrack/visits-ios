import Coordinate
import MapKit
import SwiftUI


public struct MapScreen: UIViewRepresentable {
  @Binding public var polyline: [Coordinate]
  
  public init(polyline: Binding<[Coordinate]>) {
    self._polyline = polyline
  }
  
  public func makeUIView(context: Context) -> MKMapView {
    let mapView = MKMapView()
    mapView.delegate = context.coordinator
    mapView.showsUserLocation = true
    mapView.showsCompass = false
    mapView.isRotateEnabled = false
    return mapView
  }
  
  public func updateUIView(_ mapView: MKMapView, context _: Context) {
    mapView.showsUserLocation = polyline.isEmpty
    
    putPolyline(polyline: polyline.map(\.coordinate2D), onMapView: mapView)
    zoom(withMapInsets: .all(100), interfaceInsets: nil, onMapView: mapView)
  }
  
  public func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  public class Coordinator: NSObject, MKMapViewDelegate {
    var control: MapScreen
    
    init(_ control: MapScreen) {
      self.control = control
    }
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
       return annotationViewForAnnotation(annotation, onMapView: mapView)
     }
     
    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
       return rendererForOverlay(overlay)!
     }
    
    public func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
      zoom(withMapInsets: .all(100), interfaceInsets: nil, onMapView: mapView)
    }
  }
}

