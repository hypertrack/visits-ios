import Coordinate

public struct History {
  public init(coordinates: [Coordinate], distance: UInt) {
    self.coordinates = coordinates
    self.distance = distance
  }
  
  public var coordinates: [Coordinate]
  public var distance: UInt
}
