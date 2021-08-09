import ComposableArchitecture
import Types


public struct MapDependency {
  public var openMap: (Coordinate, Address) -> Effect<Never, Never>
  public var reverseGeocode: (Coordinate) -> Effect<GeocodedResult, Never>
  
  public init(
    openMap: @escaping (Coordinate, Address) -> Effect<Never, Never>,
    reverseGeocode: @escaping (Coordinate) -> Effect<GeocodedResult, Never>
  ) {
    self.openMap = openMap
    self.reverseGeocode = reverseGeocode
  }
}
