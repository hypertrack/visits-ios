import MapKit
import Types

// MARK: - Orders

public func putOrders(
  orders: Set<Order>,
  onMapView mapView: MKMapView
) {
  mapView.removeAnnotations(mapView.annotations.compactMap { $0 as? OrderAnnotation })
  remove(overlay: OrderCircle.self, fromMapView: mapView)
  
  for order in orders {
    mapView.addAnnotation(OrderAnnotation(order: order))
    
    let destinationOverlay = OrderCircle(center: order.location.coordinate2D, radius: 50)
    destinationOverlay.order = order
    if let polylineOverlay = polyline(fromMapView: mapView) {
      mapView.insertOverlay(destinationOverlay, below: polylineOverlay)
    } else {
      mapView.addOverlay(destinationOverlay)
    }
  }
}

class OrderCircle: MKCircle {
  var order: Order!
}

// MARK: Order

public class OrderAnnotation: NSObject, MKAnnotation {
  public var coordinate: CLLocationCoordinate2D
  public let order: Order

  init(order: Order) {
    self.order = order
    self.coordinate = order.location.coordinate2D
    
    super.init()
  }
  
  public var title: String? { order.title.rawValue }
}

class OrderPendingAnnotationView: MKAnnotationView {
  override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    self.canShowCallout = true
    self.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }

  func setup() {
    frame = CGRect(x: 0, y: 0, width: 26, height: 28)
    backgroundColor = UIColor.clear
  }

  override func draw(_: CGRect) {
    if let orderAnnotation = self.annotation as? OrderAnnotation {
      drawOrder(status: orderAnnotation.order.status, visited: orderAnnotation.order.visited)
    }
  }
}

class OrderVisitedAnnotationView: MKAnnotationView {
  override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    self.canShowCallout = true
    self.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }

  func setup() {
    frame = CGRect(x: 0, y: 0, width: 26, height: 28)
    backgroundColor = UIColor.clear
  }

  override func draw(_: CGRect) {
    if let orderAnnotation = self.annotation as? OrderAnnotation {
      drawOrder(status: orderAnnotation.order.status, visited: orderAnnotation.order.visited)
    }
  }
}

class OrderCompletedAnnotationView: MKAnnotationView {
  override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    self.canShowCallout = true
    self.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }

  func setup() {
    frame = CGRect(x: 0, y: 0, width: 26, height: 28)
    backgroundColor = UIColor.clear
  }

  override func draw(_: CGRect) {
    if let orderAnnotation = self.annotation as? OrderAnnotation {
      drawOrder(status: orderAnnotation.order.status, visited: orderAnnotation.order.visited)
    }
  }
}

class OrderCanceledAnnotationView: MKAnnotationView {
  override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    self.canShowCallout = true
    self.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }

  func setup() {
    frame = CGRect(x: 0, y: 0, width: 26, height: 28)
    backgroundColor = UIColor.clear
  }

  override func draw(_: CGRect) {
    if let orderAnnotation = self.annotation as? OrderAnnotation {
      drawOrder(status: orderAnnotation.order.status, visited: orderAnnotation.order.visited)
    }
  }
}

class OrderDisabledAnnotationView: MKAnnotationView {
  override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    self.canShowCallout = true
    self.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }

  func setup() {
    frame = CGRect(x: 0, y: 0, width: 26, height: 28)
    backgroundColor = UIColor.clear
  }

  override func draw(_: CGRect) {
    if let orderAnnotation = self.annotation as? OrderAnnotation {
      drawOrder(status: orderAnnotation.order.status, visited: orderAnnotation.order.visited)
    }
  }
}

func drawOrder(status: Order.Status, visited: Order.Visited?) {
  let emoji: String
  let isVisited: Bool
  
  switch (status, visited) {
  case (.ongoing, .none): emoji = "⏳"
  case (.ongoing, .some): emoji = "📦"
  case (.completing, _),
       (.completed, _):   emoji = "🏁"
  case (.cancelling, _),
       (.cancelled, _):   emoji = "❌"
  case (.disabled, _):    emoji = "⏸"
  }
  
  switch visited {
  case .none: isVisited = false
  case .some: isVisited = true
  }
  
  //// General Declarations
  let context = UIGraphicsGetCurrentContext()!
  
  
  //// Variable Declarations
  let expression = isVisited ? UIColor(red: 0, green: 0.81, blue: 0.36, alpha: 1) : UIColor(red: 0.58, green: 0.573, blue: 0.616, alpha: 1)
  
  //// Oval Drawing
  let ovalPath = UIBezierPath(ovalIn: CGRect(x: 0, y: 1, width: 26, height: 26))
  expression.setFill()
  ovalPath.fill()
  
  
  //// Text Drawing
  let textRect = CGRect(x: 0, y: 0, width: 26, height: 28)
  let textStyle = NSMutableParagraphStyle()
  textStyle.alignment = .center
  let textFontAttributes = [
    .font: UIFont.systemFont(ofSize: UIFont.systemFontSize),
    .foregroundColor: UIColor.black,
    .paragraphStyle: textStyle,
  ] as [NSAttributedString.Key: Any]
  
  let textTextHeight: CGFloat = emoji.boundingRect(with: CGSize(width: textRect.width, height: CGFloat.infinity), options: .usesLineFragmentOrigin, attributes: textFontAttributes, context: nil).height
  context.saveGState()
  context.clip(to: textRect)
  emoji.draw(in: CGRect(x: textRect.minX, y: textRect.minY + (textRect.height - textTextHeight) / 2, width: textRect.width, height: textTextHeight), withAttributes: textFontAttributes)
  context.restoreGState()
}

// MARK: - Places

public func putPlaces(
  places: Set<Place>,
  onMapView mapView: MKMapView
) {
  mapView.removeAnnotations(mapView.annotations.compactMap { $0 as? PlaceAnnotation })
  remove(overlay: PlaceCircle.self, fromMapView: mapView)
  remove(overlay: PlacePolygon.self, fromMapView: mapView)
  
  for place in places {
    mapView.addAnnotation(PlaceAnnotation(place: place))
    
    let placeOverlay: PlaceOverlay
    
    switch place.shape {
    case let .circle(c):
      placeOverlay = PlaceCircle(center: c.center.coordinate2D, radius: CLLocationDistance(c.radius))
    case let .polygon(p):
      let pol = p.polygon.first
      let coords = ([pol.origin] + [pol.first] + [pol.second] + pol.rest).map(\.coordinate2D)
      placeOverlay = PlacePolygon(coordinates: coords, count: coords.count)
    }
    placeOverlay.place = place
    if let polylineOverlay = polyline(fromMapView: mapView) {
      mapView.insertOverlay(placeOverlay, below: polylineOverlay)
    } else {
      mapView.addOverlay(placeOverlay)
    }
  }
}

// MARK: Place

public class PlaceAnnotation: NSObject, MKAnnotation {
  public var coordinate: CLLocationCoordinate2D
  public let place: Place

  public var title: String? {
    place.title.rawValue
  }
  
  public var subtitle: String? {
    if place.name != nil, let address = place.address.anyAddressStreetBias?.rawValue {
      return address
    } else {
      return nil
    }
  }
  
  init(place: Place) {
    self.place = place
    self.coordinate = place.shape.centerCoordinate.coordinate2D
    
    super.init()
  }
}

class PlaceAnnotationView: MKAnnotationView {
  override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    self.canShowCallout = true
    self.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }

  func setup() {
    frame = CGRect(x: 0, y: 0, width: 100, height: 100)
    backgroundColor = UIColor.clear
  }

  override func draw(_: CGRect) {}
}

protocol PlaceOverlay: MKOverlay {
  var place: Place! { get set }
}

class PlaceCircle: MKCircle, PlaceOverlay {
  var place: Place!
  
//  init(center coord: CLLocationCoordinate2D, radius: CLLocationDistance, place: Place) {
//    self.place = place
//    super.init()
//    super.init(center: coord, radius: radius)
//  }
}

class PlacePolygon: MKPolygon, PlaceOverlay {
  var place: Place!
  
//  init(polygon: GeofenceShapePolygon, place: Place) {
//    self.place = place
//    super.init()
//    let pol = polygon.polygon.first
//    let coords = ([pol.origin] + [pol.first] + [pol.second] + pol.rest).map(\.coordinate2D)
//    super.init(coordinates: coords, count: coords.count)
//  }
}


// MARK: - Polyline

public func putPolyline(
  polyline: [CLLocationCoordinate2D],
  onMapView mapView: MKMapView
) {
  if let sourceAnnotation = mapView.annotations.first(
    ofType: SourceAnnotation.self
  ) {
    mapView.removeAnnotation(sourceAnnotation)
  }
  
  remove(overlay: MKPolyline.self, fromMapView: mapView)
  
  
  if polyline.count >= 2, let source = polyline.first {
    mapView.addAnnotation(SourceAnnotation(coordinate: source))
    mapView.addOverlay(
      MKPolyline(
        coordinates: polyline,
        count: polyline.count
      )
    )
  }
  
  if let device = polyline.last {
    putDevice(
      withCoordinate: device,
      bearing: 0,
      accuracy: 0,
      onMapView: mapView
    )
  } else {
    removeDeviceFrom(mapView: mapView)
  }
}

// MARK: - Device

// MARK: Put

func putDevice(
  withCoordinate coordinate: CLLocationCoordinate2D,
  bearing: CGFloat,
  accuracy: CLLocationAccuracy,
  onMapView mapView: MKMapView
) {
  if let deviceAnnotation = device(fromMapView: mapView) {
    deviceAnnotation.coordinate = coordinate
  } else {
    mapView.addAnnotation(DeviceAnnotation(
      coordinate: coordinate,
      bearing: bearing
    ))
  }
}

func remove<Overlay: MKOverlay>(
  overlay: Overlay.Type,
  fromMapView mapView: MKMapView
) {
  for someOverlay in mapView.overlays {
    if let matchingOverlay = someOverlay as? Overlay {
      mapView.removeOverlay(matchingOverlay)
    }
  }
}

func device(fromMapView mapView: MKMapView) -> DeviceAnnotation? {
  mapView.annotations.first(ofType: DeviceAnnotation.self)
}

func polyline(fromMapView mapView: MKMapView) -> MKPolyline? {
  return mapView.overlays.first(ofType: MKPolyline.self)
}

extension Array where Element: AnyObject {
  func first<T: AnyObject>(ofType _: T.Type) -> T? {
    lazy .compactMap { $0 as? T }.first
  }
}

// MARK: Remove

func removeDeviceFrom(mapView: MKMapView) {
  remove(annotation: DeviceAnnotation.self, fromMapView: mapView)
}

func remove<Annotation: MKAnnotation>(
  annotation: Annotation.Type,
  fromMapView mapView: MKMapView
) {
  if let annotation = mapView.annotations.first(ofType: Annotation.self) {
    mapView.removeAnnotation(annotation)
  }
}

// MARK: View

class DeviceAnnotation: NSObject, MKAnnotation {
  dynamic var coordinate: CLLocationCoordinate2D
  
  init(coordinate: CLLocationCoordinate2D, bearing: CGFloat) {
    self.coordinate = coordinate

    super.init()
  }
}

class DeviceAnnotationView: MKAnnotationView {

  override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }

  func setup() {
    frame = CGRect(x: 0, y: 0, width: 34, height: 34)
    backgroundColor = UIColor.clear
  }

  override func draw(_: CGRect) {
    //// General Declarations
    let context = UIGraphicsGetCurrentContext()!

    //// Color Declarations
    let green = UIColor(red: 0.00, green: 0.81, blue: 0.36, alpha: 1.00)
    let shadowColor = UIColor(red: 0.290, green: 0.290, blue: 0.290, alpha: 0.350)

    //// Shadow Declarations
    let shadow = NSShadow()
    shadow.shadowColor = shadowColor
    shadow.shadowOffset = CGSize(width: 0, height: 1)
    shadow.shadowBlurRadius = 4

    //// Oval 2 Drawing
    let oval2Path = UIBezierPath(ovalIn: CGRect(x: 4, y: 5, width: 18, height: 18))
    context.saveGState()
    context.setShadow(offset: shadow.shadowOffset, blur: shadow.shadowBlurRadius, color: (shadow.shadowColor as! UIColor).cgColor)
    UIColor.white.setFill()
    oval2Path.fill()
    context.restoreGState()



    //// Oval Drawing
    let ovalPath = UIBezierPath(ovalIn: CGRect(x: 6, y: 7, width: 14, height: 14))
    green.setFill()
    ovalPath.fill()
  }
}

// MARK: Source

class SourceAnnotation: NSObject, MKAnnotation {
  let coordinate: CLLocationCoordinate2D

  init(coordinate: CLLocationCoordinate2D) {
    self.coordinate = coordinate

    super.init()
  }
}

class SourceAnnotationView: MKAnnotationView {
  override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }

  func setup() {
    frame = CGRect(x: 0, y: 0, width: 26, height: 28)
    backgroundColor = UIColor.clear
  }

  override func draw(_: CGRect) {
    drawMarker()
  }
}

func drawMarker() {
  //// General Declarations
  let context = UIGraphicsGetCurrentContext()!

  //// Color Declarations
  let shadowColor = UIColor(red: 0.290, green: 0.290, blue: 0.290, alpha: 0.500)

  //// Shadow Declarations
  let shadow = NSShadow()
  shadow.shadowColor = shadowColor
  shadow.shadowOffset = CGSize(width: 0, height: 1)
  shadow.shadowBlurRadius = 4

  //// Variable Declarations
  let baseColor = UIColor(red: 0.00, green: 0.81, blue: 0.36, alpha: 1.00)
  let dotColor = UIColor(
      red: 1,
      green: 1,
      blue: 1,
      alpha: 1
    )

  //// Rectangle Drawing
  let rectanglePath = UIBezierPath(
    roundedRect: CGRect(x: 4, y: 5, width: 18, height: 18),
    cornerRadius: 18
  )
  context.saveGState()
  context.setShadow(
    offset: shadow.shadowOffset,
    blur: shadow.shadowBlurRadius,
    color: (shadow.shadowColor as! UIColor).cgColor
  )
  baseColor.setFill()
  rectanglePath.fill()
  context.restoreGState()

  //// Oval Drawing
  let ovalPath = UIBezierPath(
    ovalIn: CGRect(x: 9.5, y: 10.5, width: 7, height: 7)
  )
  dotColor.setFill()
  ovalPath.fill()
}

// MARK: - Zoom and center data

/// Zooms on data displayed by the `put(_:onMapView:)` function with specified
/// amount of insets in meters and/or in display points
public func zoom(
  withMapInsets mapInsets: Edges? = nil,
  interfaceInsets: Edges? = nil,
  onMapView mapView: MKMapView,
  animated: Bool = true
) {
  let maybePolyline = polyline(fromMapView: mapView)
  var coordinate: CLLocationCoordinate2D? = nil
  if let device = device(fromMapView: mapView) {
    coordinate = device.coordinate
  } else if let userLocation = mapView.userLocation.location {
    coordinate = userLocation.coordinate
  }
  let orders = mapView.annotations.compactMap { $0 as? OrderAnnotation }
  
  switch (maybePolyline, coordinate, orders.isEmpty) {
  
  case (.none, .none, true): return
  
  case let (maybePolyline, coordinate, _):
    var coordinateCloud: [CLLocationCoordinate2D] = []
    
    if let polyline = maybePolyline {
      coordinateCloud += coordinatesFromMultiPoint(polyline)
    }
    
    if let coordinate = coordinate {
      coordinateCloud += [coordinate]
    }
    
    coordinateCloud += orders.map(\.order.location.coordinate2D)
    
    if !coordinateCloud.isEmpty {
      var mapRect = mapRectFromCoordinates(coordinateCloud)
      
      if let mapInsets = mapInsets {
        mapRect = outset(mapRect: mapRect, withEdges: mapInsets)
      }
      
      if let interfaceInsets = interfaceInsets {
        let (top, leading, bottom, trailing) = interfaceInsets.unpack()
        mapView.setVisibleMapRect(
          mapRect,
          edgePadding: UIEdgeInsets(
            top: CGFloat(top),
            left: CGFloat(leading),
            bottom: CGFloat(bottom),
            right: CGFloat(trailing)
          ),
          animated: animated
        )
      } else {
        mapView.setVisibleMapRect(mapRect, animated: animated)
      }
    }
  }
}

func mapRectFromCoordinates(
  _ coordinates: [CLLocationCoordinate2D]
) -> MKMapRect {
  let rects = coordinates.lazy
    .map { MKMapRect(origin: MKMapPoint($0), size: MKMapSize()) }
  return rects.reduce(MKMapRect.null) { $0.union($1) }
}

func outset(mapRect: MKMapRect, withEdges edges: Edges) -> MKMapRect {
  let (top, leading, bottom, trailing) = edges.unpack()
  let pointsPerMeter = MKMapPointsPerMeterAtLatitude(mapRect.origin.coordinate
    .latitude)
  let topPoints = Double(top) * pointsPerMeter
  let leadingPoints = Double(leading) * pointsPerMeter
  let bottomPoints = Double(bottom) * pointsPerMeter
  let trailingPoints = Double(trailing) * pointsPerMeter
  return MKMapRect(
    x: mapRect.minX - leadingPoints,
    y: mapRect.minY - topPoints,
    width: mapRect.width + leadingPoints + trailingPoints,
    height: mapRect.height + topPoints + bottomPoints
  )
}

func coordinatesFromMultiPoint(_ multiPoint: MKMultiPoint) -> [
  CLLocationCoordinate2D
] {
  var coordinates = [CLLocationCoordinate2D](
    repeating: kCLLocationCoordinate2DInvalid,
    count: multiPoint.pointCount
  )
  multiPoint.getCoordinates(
    &coordinates,
    range: NSRange(location: 0, length: multiPoint.pointCount)
  )

  return coordinates
}

/// Enum representing map edges, and amound of insets to apply
public enum Edges {
  /// For mapInsets amount represents meters and for interfaceInsets it
  /// represents display points
  public typealias Amount = UInt16

  /// Apply the same amound for all edges
  case all(Amount)
  /// Apply the amount only for the bottom edge
  case bottom(Amount)
  /// Apply custom amount for every edge
  case custom(top: Amount, leading: Amount, bottom: Amount, trailing: Amount)
  /// Apply the same amount for leading and trailing edges
  case horizontal(Amount)
  /// Apply the amount only for the leading edge
  case leading(Amount)
  /// Apply the amount only for the top edge
  case top(Amount)
  /// Apply the amount only for the trailing edge
  case trailing(Amount)
  /// Apply the same amount for top and bottom edges
  case vertical(Amount)

  func unpack() -> (
    top: Amount,
    leading: Amount,
    bottom: Amount,
    trailing: Amount
  ) {
    switch self {
      case let .all(amount):
        return (amount, amount, amount, amount)
      case let .bottom(amount):
        return (0, 0, amount, 0)
      case let .custom(top, leading, bottom, trailing):
        return (top, leading, bottom, trailing)
      case let .horizontal(amount):
        return (0, amount, 0, amount)
      case let .leading(amount):
        return (0, amount, 0, 0)
      case let .top(amount):
        return (amount, 0, 0, 0)
      case let .trailing(amount):
        return (0, 0, 0, amount)
      case let .vertical(amount):
        return (amount, 0, amount, 0)
    }
  }
}

// MARK: - Views


let deviceAnnoationID = "DeviceAnnotation"
let sourceAnnotationID = "SourceAnnotation"
let orderPendingAnnotationID = "OrderPendingAnnotation"
let orderVisitedAnnotationID = "OrderVisitedAnnotation"
let orderCompletedAnnotationID = "OrderCompletedAnnotation"
let orderCanceledAnnotationID = "OrderCanceledAnnotation"
let orderDisabledAnnotationID = "OrderDisabledAnnotation"
let placeAnnotationID = "PlaceAnnotation"


public func registerAnnotations(for mapView: MKMapView) {
  mapView.register(DeviceAnnotationView.self, forAnnotationViewWithReuseIdentifier: deviceAnnoationID)
  mapView.register(SourceAnnotationView.self, forAnnotationViewWithReuseIdentifier: sourceAnnotationID)
  mapView.register(OrderPendingAnnotationView.self, forAnnotationViewWithReuseIdentifier: orderPendingAnnotationID)
  mapView.register(OrderVisitedAnnotationView.self, forAnnotationViewWithReuseIdentifier: orderVisitedAnnotationID)
  mapView.register(OrderCompletedAnnotationView.self, forAnnotationViewWithReuseIdentifier: orderCompletedAnnotationID)
  mapView.register(OrderCanceledAnnotationView.self, forAnnotationViewWithReuseIdentifier: orderCanceledAnnotationID)
  mapView.register(OrderDisabledAnnotationView.self, forAnnotationViewWithReuseIdentifier: orderDisabledAnnotationID)
  mapView.register(PlaceAnnotationView.self, forAnnotationViewWithReuseIdentifier: placeAnnotationID)
}

public func annotationViewForAnnotation(
  _ annotation: MKAnnotation,
  onMapView mapView: MKMapView
) -> MKAnnotationView? {
  switch annotation {
  case let deviceAnnotation as DeviceAnnotation:
    return mapView.dequeueReusableAnnotationView(withIdentifier: deviceAnnoationID, for: deviceAnnotation)
  case let sourceAnnotation as SourceAnnotation:
    return mapView.dequeueReusableAnnotationView(withIdentifier: sourceAnnotationID, for: sourceAnnotation)
  case let orderAnnotation as OrderAnnotation:
    let reuseIdentifier: String
    switch (orderAnnotation.order.status, orderAnnotation.order.visited) {
    case (.ongoing, .none): reuseIdentifier = orderPendingAnnotationID
    case (.ongoing, .some): reuseIdentifier = orderVisitedAnnotationID
    case (.completing, _),
         (.completed, _):   reuseIdentifier = orderCompletedAnnotationID
    case (.cancelling, _),
         (.cancelled, _):   reuseIdentifier = orderCanceledAnnotationID
    case (.disabled, _):    reuseIdentifier = orderDisabledAnnotationID
    }
    return mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier, for: orderAnnotation)
  case let placeAnnotation as PlaceAnnotation:
    return mapView.dequeueReusableAnnotationView(withIdentifier: placeAnnotationID, for: placeAnnotation)
  default:
    return nil
  }
}

/// Returns the rederer for Views SDK overlays or nil if no overlays found
public func rendererForOverlay(
  _ overlay: MKOverlay
) -> MKOverlayRenderer? {
  typealias RGB = (red: CGFloat, green: CGFloat, blue: CGFloat)
  let grey: RGB =  (0.58, 0.573, 0.616)
  let green: RGB = (0.0,  0.81,  0.36)
  let fillAlpha: CGFloat   = 0.36
  let strokeAlpha: CGFloat = 1.0
  let color = { (c: RGB, a: CGFloat) in UIColor(red: c.red, green: c.green, blue: c.blue, alpha: a) }
  let fillColor = { c in color(c, fillAlpha) }
  let strokeColor = { c in color(c, strokeAlpha) }
  
  let greyFill = fillColor(grey)
  let greenFill = fillColor(green)
  let greyStroke = strokeColor(grey)
  let greenStroke = strokeColor(green)
  
  let rendererSelectedStyle = { (s: Bool, r: MKOverlayPathRenderer) -> MKOverlayPathRenderer in
    let fillColor = s ? greenFill : greyFill
    let strokeColor = s ? greenStroke : greyStroke
    r.fillColor = fillColor
    
    r.strokeColor = strokeColor
    r.lineWidth = 1
    
    return r
  }
  
  switch overlay {
  case let orderCircle as OrderCircle:
    return rendererSelectedStyle(
      orderCircle.order.visited != nil,
      MKCircleRenderer(circle: orderCircle) as MKOverlayPathRenderer
    )
  case let placeCircle as PlaceCircle:
    return rendererSelectedStyle(
      placeCircle.place.visited,
      MKCircleRenderer(circle: placeCircle) as MKOverlayPathRenderer
    )
  case let placePolygon as PlacePolygon:
    return rendererSelectedStyle(
      placePolygon.place.visited,
      MKPolygonRenderer(polygon: placePolygon) as MKOverlayPathRenderer
    )
  case let polyline as MKPolyline:
    let polylineRenderer = MKPolylineRenderer(polyline: polyline)
    polylineRenderer.strokeColor = UIColor(
      red: 0.0 / 255.0,
      green: 206.0 / 255.0,
      blue: 91.0 / 255.0,
      alpha: 1.0
    )
    polylineRenderer.lineWidth = 3.0
    polylineRenderer.lineJoin = .round
    polylineRenderer.lineCap = .round
    return polylineRenderer
  default:
    return nil
  }
}
 
public enum CalloutSource {
  case order(Order)
  case place(Place)
}

public func calloutAccessoryControlTapped(for annotationView: MKAnnotationView) -> CalloutSource? {
  switch annotationView {
  case is OrderPendingAnnotationView,
       is OrderVisitedAnnotationView,
       is OrderCompletedAnnotationView,
       is OrderCanceledAnnotationView,
       is OrderDisabledAnnotationView:
    return .order((annotationView.annotation as! OrderAnnotation).order)
  case is PlaceAnnotationView:
    return .place((annotationView.annotation as! PlaceAnnotation).place)
  default:
    return nil
  }
}
