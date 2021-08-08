import ComposableArchitecture
import Types


public struct MapDependency {
  public var openMap: (Coordinate, Address) -> Effect<Never, Never>
  
  public init(
    openMap: @escaping (Coordinate, Address) -> Effect<Never, Never>
  ) {
    self.openMap = openMap
  }
}
