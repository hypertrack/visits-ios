import ComposableArchitecture
import Prelude
import Types


public struct MapEnvironment {
  public var openMap: (Coordinate, Either<Visit.FullAddress, Visit.Street>?) -> Effect<Never, Never>
  
  public init(
    openMap: @escaping (Coordinate, Either<Visit.FullAddress, Visit.Street>?) -> Effect<Never, Never>
  ) {
    self.openMap = openMap
  }
}
