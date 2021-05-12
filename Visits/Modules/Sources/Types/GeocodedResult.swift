public struct GeocodedResult: Equatable {
  public var coordinate: Coordinate
  public var address: Address
  
  public init(coordinate: Coordinate, address: Address) {
    self.coordinate = coordinate
    self.address = address
  }
}
