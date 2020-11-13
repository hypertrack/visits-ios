import ComposableArchitecture
import Coordinate
import Prelude
import Visit


public struct MapEnvironment {
  public var openMap: (Coordinate, Either<AssignedVisit.FullAddress, AssignedVisit.Street>?) -> Effect<Never, Never>
  
  public init(
    openMap: @escaping (Coordinate, Either<AssignedVisit.FullAddress, AssignedVisit.Street>?) -> Effect<Never, Never>
  ) {
    self.openMap = openMap
  }
}
