import Coordinate

public struct History: Equatable {
  public init(coordinates: [Coordinate], distance: UInt) {
    self.coordinates = coordinates
    self.distance = distance
  }
  
  public var coordinates: [Coordinate]
  public var distance: UInt
}
