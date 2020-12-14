import MapKit

// MARK: - Visits

func putVisits(
  visits: [MapVisit],
  onMapView mapView: MKMapView
) {
  mapView.removeAnnotations(mapView.annotations.compactMap { $0 as? VisitAnnotation })
  
  for visit in visits {
    mapView.addAnnotation(VisitAnnotation(visit: visit))
  }
}

// MARK: Visit

class VisitAnnotation: NSObject, MKAnnotation {
  var coordinate: CLLocationCoordinate2D
  let visit: MapVisit

  init(visit: MapVisit) {
    self.visit = visit
    self.coordinate = visit.coordinate.coordinate2D
    
    super.init()
  }
}

class VisitPendingAnnotationView: MKAnnotationView {
  init(annotation: VisitAnnotation, reuseIdentifier: String) {
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
    drawVisit(.pending)
  }
}

class VisitVisitedAnnotationView: MKAnnotationView {
  init(annotation: VisitAnnotation, reuseIdentifier: String) {
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
    drawVisit(.visited)
  }
}

class VisitCompletedAnnotationView: MKAnnotationView {
  init(annotation: VisitAnnotation, reuseIdentifier: String) {
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
    drawVisit(.completed)
  }
}

class VisitCanceledAnnotationView: MKAnnotationView {
  init(annotation: VisitAnnotation, reuseIdentifier: String) {
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
    drawVisit(.canceled)
  }
}

func drawVisit(_ visitStatus: MapVisit.Status) {
  let emoji: String
  switch visitStatus {
  case .pending: emoji = "⏳"
  case .visited: emoji = "📦"
  case .completed: emoji = "🏁"
  case .canceled: emoji = "❌"
  }
  
  //// General Declarations
  let context = UIGraphicsGetCurrentContext()!
  
  //// Text Drawing
  let textRect = CGRect(x: 0, y: 0, width: 26, height: 28)
  let textStyle = NSMutableParagraphStyle()
  textStyle.alignment = .center
  let textFontAttributes = [
    .font: UIFont.systemFont(ofSize: 24),
    .foregroundColor: UIColor.black,
    .paragraphStyle: textStyle,
  ] as [NSAttributedString.Key: Any]
  
  let textTextHeight: CGFloat = emoji.boundingRect(with: CGSize(width: textRect.width, height: CGFloat.infinity), options: .usesLineFragmentOrigin, attributes: textFontAttributes, context: nil).height
  context.saveGState()
  context.clip(to: textRect)
  emoji.draw(in: CGRect(x: textRect.minX, y: textRect.minY + (textRect.height - textTextHeight) / 2, width: textRect.width, height: textTextHeight), withAttributes: textFontAttributes)
  context.restoreGState()
}

// MARK: - Polyline

func putPolyline(
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
  remove(overlay: MKCircle.self, fromMapView: mapView)
  if accuracy > 0 {
    let accuracyCircleOverlay = MKCircle(center: coordinate, radius: accuracy)
    if let polylineOverlay = polyline(fromMapView: mapView) {
      mapView.insertOverlay(accuracyCircleOverlay, above: polylineOverlay)
    } else {
      mapView.addOverlay(accuracyCircleOverlay)
    }
  }
}

func remove<Overlay: MKOverlay>(
  overlay: Overlay.Type,
  fromMapView mapView: MKMapView
) {
  if let overlay = mapView.overlays.first(ofType: Overlay.self) {
    mapView.removeOverlay(overlay)
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
  remove(overlay: MKCircle.self, fromMapView: mapView)
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

  init(annotation: DeviceAnnotation, reuseIdentifier: String) {
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
  init(annotation: MKAnnotation, reuseIdentifier: String) {
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
  let visits = mapView.annotations.compactMap { $0 as? VisitAnnotation }
  
  switch (maybePolyline, coordinate, visits.isEmpty) {
  
  case (.none, .none, true): return
  
  case let (maybePolyline, coordinate, _):
    var coordinateCloud: [CLLocationCoordinate2D] = []
    
    if let polyline = maybePolyline {
      coordinateCloud += coordinatesFromMultiPoint(polyline)
    }
    
    if let coordinate = coordinate {
      coordinateCloud += [coordinate]
    }
    
    coordinateCloud += visits.map(\.visit.coordinate.coordinate2D)
    
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

public func annotationViewForAnnotation(
  _ annotation: MKAnnotation,
  onMapView mapView: MKMapView
) -> MKAnnotationView? {
  if let deviceAnnotation = annotation as? DeviceAnnotation {
    let reuseIdentifier = "DeviceAnnotation"
    if let deviceAnnotationView = mapView.dequeueReusableAnnotationView(
      withIdentifier: reuseIdentifier
    ) {
      return deviceAnnotationView
    } else {
      return DeviceAnnotationView(
        annotation: deviceAnnotation,
        reuseIdentifier: reuseIdentifier
      )
    }
  } else if let sourceAnnotation = annotation as? SourceAnnotation {
    let reuseIdentifier = "SourceAnnotation"
    if let sourceAnnotationView = mapView.dequeueReusableAnnotationView(
      withIdentifier: reuseIdentifier
    ) {
      return sourceAnnotationView
    } else {
      return SourceAnnotationView(
        annotation: sourceAnnotation,
        reuseIdentifier: reuseIdentifier
      )
    }
  } else if let visitAnnotation = annotation as? VisitAnnotation {
    let reuseIdentifier: String
    switch visitAnnotation.visit.status {
    case .pending:   reuseIdentifier = "VisitPendingAnnotation"
    case .visited:   reuseIdentifier = "VisitVisitedAnnotation"
    case .completed: reuseIdentifier = "VisitCompletedAnnotation"
    case .canceled:  reuseIdentifier = "VisitCanceledAnnotation"
    }
    if let visitAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) {
      return visitAnnotationView
    } else {
      switch visitAnnotation.visit.status {
      case .pending:   return VisitPendingAnnotationView(annotation: visitAnnotation, reuseIdentifier: reuseIdentifier)
      case .visited:   return VisitVisitedAnnotationView(annotation: visitAnnotation, reuseIdentifier: reuseIdentifier)
      case .completed: return VisitCompletedAnnotationView(annotation: visitAnnotation, reuseIdentifier: reuseIdentifier)
      case .canceled:  return VisitCanceledAnnotationView(annotation: visitAnnotation, reuseIdentifier: reuseIdentifier)
      }
    }
  } else {
    return nil
  }
}

/// Returns the rederer for Views SDK overlays or nil if no overlays found
public func rendererForOverlay(
  _ overlay: MKOverlay
) -> MKOverlayRenderer? {
  if overlay is MKCircle {
    let circleRenderer = MKCircleRenderer(circle: overlay as! MKCircle)
    circleRenderer.fillColor = UIColor(
      red: 0.0 / 255.0,
      green: 206.0 / 255.0,
      blue: 91.0 / 255.0,
      alpha: 0.24
    )
    circleRenderer.lineWidth = 1.5
    return circleRenderer
  } else if overlay is MKPolyline {
    let polylineRenderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
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
  } else {
    return nil
  }
}
