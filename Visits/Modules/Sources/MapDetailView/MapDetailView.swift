import Foundation
import MapDrawing
import MapKit
import SwiftUI
import Types


public enum MapDetailObject {
  case order(Order)
  case place(Place)
}


public struct MapDetailView: UIViewRepresentable {
  private let object: MapDetailObject
  
  public init(object: MapDetailObject) {
    self.object = object
  }
  
  public func makeUIView(context: Context) -> MKMapView {
    let mapView = MKMapView()
    mapView.delegate = context.coordinator
    mapView.showsUserLocation = true
    mapView.showsCompass = false
    mapView.isRotateEnabled = false
    mapView.isUserInteractionEnabled = false
    registerAnnotations(for: mapView)
    return mapView
  }

  public func updateUIView(_ mapView: MKMapView, context _: Context) {
    switch object {
    case let .order(o): putOrders(orders: [o], onMapView: mapView)
    case let .place(p): putPlaces(places: [p], onMapView: mapView)
    }
    
    if let overlay = mapView.overlays.first {
      mapView.setVisibleMapRect(
        overlay.boundingMapRect,
        edgePadding: insets,
        animated: false
      )
    }
  }
  
  public static func dismantleUIView(_ mapView: MKMapView, coordinator: ()) {
    removeOrdersFrom(mapView: mapView)
    removePlacesFrom(mapView: mapView)
  }
  
  public func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  public class Coordinator: NSObject, MKMapViewDelegate {
    var control: MapDetailView
    
    init(_ control: MapDetailView) {
      self.control = control
    }
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
      annotationViewForAnnotation(annotation, onMapView: mapView)
    }
    
    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
      rendererForOverlay(overlay)!
    }
  }
}

let inset: CGFloat = 5
let insets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
