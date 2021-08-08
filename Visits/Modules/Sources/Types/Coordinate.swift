import CoreLocation

public struct Coordinate: Hashable {
  public let latitude: Double
  public let longitude: Double
  public var coordinate2D: CLLocationCoordinate2D {
    .init(latitude: latitude, longitude: longitude)
  }
  
  public init?(latitude: Double, longitude: Double) {
    self.init(
      coordinate2D: CLLocationCoordinate2D(
        latitude: latitude,
        longitude: longitude
      )
    )
  }
  
  public init?(coordinate2D: CLLocationCoordinate2D) {
    if CLLocationCoordinate2DIsValid(coordinate2D) {
      self.latitude = coordinate2D.latitude
      self.longitude = coordinate2D.longitude
    } else {
      return nil
    }
  }
  
  public func distance(from coordinate: Coordinate) -> Double {
    CLLocation(latitude: self.latitude, longitude: self.longitude)
      .distance(
        from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
      )
  }
}

extension Coordinate: Equatable {}
extension Coordinate: Codable {}
