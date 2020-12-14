import Coordinate
import MapKit
import SwiftUI

public struct MapVisit: Equatable {
  public enum Status: Equatable {
    case pending, visited, completed, canceled
  }
  
  public let id: String
  public let coordinate: Coordinate
  public let status: Status
  
  public init(id: String, coordinate: Coordinate, status: Status) {
    self.id = id
    self.coordinate = coordinate
    self.status = status
  }
}

public struct MapScreen: UIViewRepresentable {
  @Binding public var polyline: [Coordinate]
  @Binding public var visits: [MapVisit]
  var sendSelectedMapVisit: (String) -> Void
  
  public init(polyline: Binding<[Coordinate]>, sendSelectedMapVisit: @escaping (String) -> Void, visits: Binding<[MapVisit]>) {
    self._polyline = polyline
    self.sendSelectedMapVisit = sendSelectedMapVisit
    self._visits = visits
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
    putVisits(visits: visits, onMapView: mapView)
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
    
    public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
      if let visitAnnotation = view.annotation as? VisitAnnotation {
        control.sendSelectedMapVisit(visitAnnotation.visit.id)
      }
    }
  }
}

