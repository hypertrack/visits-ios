import Coordinate
import Foundation
import NonEmpty
import Prelude


public enum GeoJSON {
  case point(Coordinate)
  case lineString(Either<NonEmptyArray<Coordinate>, NonEmptyArray<Location>>?)
  case polygon(NonEmptyArray<LinearRing>)
}

public struct Location {
  public let coordinate: Coordinate
  public let recordedAt: Date
}

public struct LinearRing {
  public let origin: Coordinate
  public let first: Coordinate
  public let second: Coordinate
  public let rest: [Coordinate]
}

// MARK: - Equatable

extension GeoJSON: Equatable {}
extension Location: Equatable {}
extension LinearRing: Equatable {}
