import IdentifiedCollections
import MapDrawing
import MapKit
import SwiftUI
import Types
import Views

public struct MapView: View {
  public struct State: Equatable {
    public var autoZoom: AutoZoom
    public var clockedIn: Bool
    public var orders: IdentifiedArrayOf<Order>
    public var places: Set<Place>
    public var polyline: [Coordinate]

    public init(
      autoZoom: AutoZoom, 
      clockedIn: Bool,
      orders: IdentifiedArrayOf<Order>, 
      places: Set<Place>, 
      polyline: [Coordinate]
    ) {
      self.autoZoom = autoZoom; 
      self.clockedIn = clockedIn;
      self.orders = orders; 
      self.places = places; 
      self.polyline = polyline
    }
  }

  public enum Action: Equatable {
    case clockInToggleTapped
    case regionDidChange
    case regionWillChange
    case selectedOrder(Order)
    case selectedPlace(Place)
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
    NavigationView {
      ZStack {
        MapViewRepresentable(
          polyline: state.polyline,
          orders: state.orders,
          places: state.places,
          autoZoom: state.autoZoom,
          sendSelectedOrder: { send(.selectedOrder($0)) },
          sendSelectedPlace: { send(.selectedPlace($0)) },
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
      }.toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: {
             send(.clockInToggleTapped)
          }
          ) {
            Text(state.clockedIn ? "Clock Out" : "Clock In")
              .foregroundColor(state.clockedIn ? .gray : .accentColor)
          }
        }
      }
      .navigationBarTitle(
        state.clockedIn
          ? Text("")
        : Text("Visits are not tracked").font(.tinyMedium),
        displayMode: .inline)
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }
}

struct MapViewRepresentable: UIViewRepresentable {
  var polyline: [Coordinate]
  var orders: IdentifiedArrayOf<Order>
  var places: Set<Place>
  var autoZoom: AutoZoom
  var sendSelectedOrder: (Order) -> Void
  var sendSelectedPlace: (Place) -> Void
  var sendRegionDidChange: () -> Void
  var sendRegionWillChange: () -> Void

  func makeUIView(context: Context) -> MKMapView {
    let mapView = MKMapView()
    mapView.delegate = context.coordinator
    mapView.showsUserLocation = true
    mapView.showsCompass = false
    mapView.isRotateEnabled = false
    registerAnnotations(for: mapView)
    return mapView
  }

  func updateUIView(_ mapView: MKMapView, context _: Context) {
    mapView.showsUserLocation = polyline.isEmpty

    putPolyline(polyline: polyline.map(\.coordinate2D), onMapView: mapView)
    putOrders(orders: orders.elements, onMapView: mapView)
    putPlaces(places: places, onMapView: mapView)
    zoomIfNeeded(onMapView: mapView)
  }

  func zoomIfNeeded(onMapView mapView: MKMapView) {
    if autoZoom == .enabled {
      zoom(withMapInsets: .all(100), interfaceInsets: nil, onMapView: mapView)
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  class Coordinator: NSObject, MKMapViewDelegate {
    var control: MapViewRepresentable

    init(_ control: MapViewRepresentable) {
      self.control = control
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
      annotationViewForAnnotation(annotation, onMapView: mapView)
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
      rendererForOverlay(overlay)!
    }

    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
      control.zoomIfNeeded(onMapView: mapView)
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
      if control.autoZoom == .enabled,
         mapViewRegionDidChangeFromUserInteraction(mapView)
      {
        control.sendRegionDidChange()
      }
    }

    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
      if control.autoZoom == .enabled,
         mapViewRegionDidChangeFromUserInteraction(mapView)
      {
        control.sendRegionWillChange()
      }
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped c: UIControl) {
      switch calloutAccessoryControlTapped(for: view) {
      case let .order(o): control.sendSelectedOrder(o)
      case let .place(p): control.sendSelectedPlace(p)
      default: break
      }
    }
  }
}

func mapViewRegionDidChangeFromUserInteraction(
  _ mapView: MKMapView
) -> Bool {
  let view = mapView.subviews[0]
  //  Look through gesture recognizers to determine
  // whether this region change is from user interaction
  if let gestureRecognizers = view.gestureRecognizers {
    for recognizer in gestureRecognizers {
      if recognizer.state == UIGestureRecognizer.State.began ||
        recognizer.state == UIGestureRecognizer.State.ended
      {
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
        clockedIn: true,
        orders: [
          .init(
            id: Order.ID(rawValue: "ID5"),
            createdAt: Calendar.current.date(bySettingHour: 9, minute: 38, second: 0, of: Date())!,
            location: Coordinate(latitude: 37.783049, longitude: -122.418242)!,
            address: .init(
              street: Street(rawValue: "601 Eddy St"),
              fullAddress: FullAddress(rawValue: "601 Eddy St, San Francisco, CA  94109, United States")
            ),
            status: .completed(Date()),
            note: nil,
            visited: .entered(Date())
          ),
        ],
        places: [],
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
          Coordinate(latitude: 37.78315503056424, longitude: -122.41850852966309)!,
        ]
      ),
      send: { _ in }
    )
    .preferredColorScheme(.dark)
  }
}
