import MapKit
import SwiftUI
import Types


public struct MapView: View {
  
  public struct State: Equatable {
    public var autoZoom: AutoZoom
    public var orders: Set<Order>
    public var polyline: [Coordinate]
    
    public init(autoZoom: AutoZoom, orders: Set<Order>, polyline: [Coordinate]) {
      self.autoZoom = autoZoom; self.orders = orders; self.polyline = polyline
    }
  }
  
  public enum Action: Equatable {
    case regionDidChange
    case regionWillChange
    case selectedOrder(Order)
    case enableAutoZoom
  }
  
  let state: State
  let send: (Action) -> Void
  
  public init(
    state: State,
    send: @escaping (Action) -> Void
  ) {
    self.state = state
    self.send = send
  }
  
  public var body: some View {
    ZStack {
      MapViewRepresentable(
        polyline: state.polyline,
        orders: state.orders,
        autoZoom: state.autoZoom,
        sendSelectedMapOrder: { send(.selectedOrder($0)) },
        sendRegionDidChange: { send(.regionDidChange) },
        sendRegionWillChange: { send(.regionWillChange) }
      )
      if state.autoZoom == .disabled {
        HStack {
          Spacer()
          VStack {
            AutoZoomButton(
              sendEnableAutoZoom: {
                send(.enableAutoZoom)
              
              }
            )
              .padding(.trailing, 16)
              .padding(.top, 48)
            Spacer()
          }
        }
      }
    }
  }
}

public struct MapViewRepresentable: UIViewRepresentable {
  public var polyline: [Coordinate]
  public var orders: Set<Order>
  public var autoZoom: AutoZoom
  var sendSelectedMapOrder: (Order) -> Void
  var sendRegionDidChange: () -> Void
  var sendRegionWillChange: () -> Void
  
  public init(
    polyline: [Coordinate],
    orders: Set<Order>,
    autoZoom: AutoZoom,
    sendSelectedMapOrder: @escaping (Order) -> Void,
    sendRegionDidChange: @escaping () -> Void,
    sendRegionWillChange: @escaping () -> Void
  ) {
    self.polyline = polyline
    self.orders = orders
    self.autoZoom = autoZoom
    self.sendSelectedMapOrder = sendSelectedMapOrder
    self.sendRegionDidChange = sendRegionDidChange
    self.sendRegionWillChange = sendRegionWillChange
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
    putOrders(orders: orders, onMapView: mapView)
    zoomIfNeeded(onMapView: mapView)
  }
  
  func zoomIfNeeded(onMapView mapView: MKMapView) {
    if autoZoom == .enabled {
      zoom(withMapInsets: .all(100), interfaceInsets: nil, onMapView: mapView)
    }
  }
  
  public func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  public class Coordinator: NSObject, MKMapViewDelegate {
    var control: MapViewRepresentable
    
    init(_ control: MapViewRepresentable) {
      self.control = control
    }
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
      return annotationViewForAnnotation(annotation, onMapView: mapView)
    }
    
    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
      return rendererForOverlay(overlay)!
    }
    
    public func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
      control.zoomIfNeeded(onMapView: mapView)
    }
    
    public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
      if let orderAnnotation = view.annotation as? OrderAnnotation {
        control.sendSelectedMapOrder(orderAnnotation.order)
      }
    }
    
    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
      if control.autoZoom == .enabled,
         mapViewRegionDidChangeFromUserInteraction(mapView){
        control.sendRegionDidChange()
      }
    }
    
    public func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
      if control.autoZoom == .enabled,
         mapViewRegionDidChangeFromUserInteraction(mapView){
        control.sendRegionWillChange()
      }
    }
  }
}

public func mapViewRegionDidChangeFromUserInteraction(
  _ mapView: MKMapView
) -> Bool {
  let view = mapView.subviews[0]
  //  Look through gesture recognizers to determine
  // whether this region change is from user interaction
  if let gestureRecognizers = view.gestureRecognizers {
    for recognizer in gestureRecognizers {
      if recognizer.state == UIGestureRecognizer.State.began ||
          recognizer.state == UIGestureRecognizer.State.ended {
        return true
      }
    }
  }
  return false
}


struct MapView_Previews: PreviewProvider {
  static var previews: some View {
    MapView(
      state: .init(
        autoZoom: .enabled,
        orders: [
          .init(
            id: Order.ID(rawValue: "ID5"),
            tripID: "_",
            createdAt: Calendar.current.date(bySettingHour: 9, minute: 38, second: 0, of: Date())!,
            location: Coordinate(latitude: 37.783049, longitude: -122.418242)!,
            address: .init(
              street: Street(rawValue: "601 Eddy St"),
              fullAddress: FullAddress(rawValue: "601 Eddy St, San Francisco, CA  94109, United States")
            ),
            status: .completed(Date()),
            note: nil,
            visited: .entered(Date())
          )
        ],
        polyline: [
          Coordinate(latitude: 37.76477793772538, longitude: -122.41957068443297)!,
          Coordinate(latitude: 37.76477793772538, longitude: -122.4196484684944)!,
          Coordinate(latitude: 37.77180875405714, longitude: -122.42035388946533)!,
          Coordinate(latitude: 37.7730130005326, longitude: -122.42180228233337)!,
          Coordinate(latitude: 37.773962814902774, longitude: -122.42069721221922)!,
          Coordinate(latitude: 37.776659542769934, longitude: -122.42124438285828)!,
          Coordinate(latitude: 37.77676978426915, longitude: -122.42056846618652)!,
          Coordinate(latitude: 37.77657474150483, longitude: -122.42050409317015)!,
          Coordinate(latitude: 37.77662562227558, longitude: -122.42010712623598)!,
          Coordinate(latitude: 37.77690546588866, longitude: -122.42021441459654)!,
          Coordinate(latitude: 37.77686306540933, longitude: -122.42057919502257)!,
          Coordinate(latitude: 37.77676978426915, longitude: -122.4204933643341)!,
          Coordinate(latitude: 37.77671890359764, longitude: -122.42127656936647)!,
          Coordinate(latitude: 37.77894914015784, longitude: -122.42174863815306)!,
          Coordinate(latitude: 37.77886434151916, longitude: -122.42224216461183)!,
          Coordinate(latitude: 37.77883042203647, longitude: -122.4221885204315)!,
          Coordinate(latitude: 37.77883042203647, longitude: -122.42229580879211)!,
          Coordinate(latitude: 37.779000019294344, longitude: -122.42170572280882)!,
          Coordinate(latitude: 37.77989039851448, longitude: -122.42190957069396)!,
          Coordinate(latitude: 37.780085432530804, longitude: -122.42036461830139)!,
          Coordinate(latitude: 37.774929577713245, longitude: -122.41936683654784)!,
          Coordinate(latitude: 37.77681218480201, longitude: -122.41704940795898)!,
          Coordinate(latitude: 37.77671890359764, longitude: -122.41700649261476)!,
          Coordinate(latitude: 37.77682066490566, longitude: -122.41694211959839)!,
          Coordinate(latitude: 37.77686306540933, longitude: -122.41694211959839)!,
          Coordinate(latitude: 37.77739730967186, longitude: -122.41634130477905)!,
          Coordinate(latitude: 37.78331613854221, longitude: -122.41753220558167)!,
          Coordinate(latitude: 37.78321438617593, longitude: -122.41843342781067)!,
          Coordinate(latitude: 37.78309567490489, longitude: -122.41842806339264)!,
          Coordinate(latitude: 37.783019360415665, longitude: -122.4183851480484)!,
          Coordinate(latitude: 37.78315503056424, longitude: -122.41850852966309)!
        ]
      ),
      send: { _ in }
    )
      .preferredColorScheme(.dark)
  }
}
