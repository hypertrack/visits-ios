import Foundation
import NonEmpty


public enum GeofenceShape {
  case circle(GeofenceShapeCircle)
  case polygon(GeofenceShapePolygon)
}

public struct GeofenceShapeCircle {
  public var center: Coordinate
  public var radius: UInt
  
  public init(center: Coordinate, radius: UInt) {
    self.center = center
    self.radius = radius
  }
}

public struct GeofenceShapePolygon {
  public var centroid: Coordinate
  public var polygon: NonEmptyArray<LinearRing>
  
  public init(centroid: Coordinate, polygon: NonEmptyArray<LinearRing>) {
    self.centroid = centroid
    self.polygon = polygon
  }
}

public extension GeofenceShape {
  var centerCoordinate: Coordinate {
    switch self {
    case let .circle(c):  return c.center
    case let .polygon(p): return p.centroid
    }
  }
}

extension GeofenceShape: Equatable {}
extension GeofenceShapeCircle: Equatable {}
extension GeofenceShapePolygon: Equatable {}

extension GeofenceShapeCircle: Codable {}
extension GeofenceShapePolygon: Codable {}
extension GeofenceShape: AutoCodable {}
