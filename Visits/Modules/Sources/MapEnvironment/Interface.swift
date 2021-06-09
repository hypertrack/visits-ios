import ComposableArchitecture
import Utility
import Types


public struct MapEnvironment {
  public var openMap: (Coordinate, Either<FullAddress, Street>?) -> Effect<Never, Never>
  
  public init(
    openMap: @escaping (Coordinate, Either<FullAddress, Street>?) -> Effect<Never, Never>
  ) {
    self.openMap = openMap
  }
}
