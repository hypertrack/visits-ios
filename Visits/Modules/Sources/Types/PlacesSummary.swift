import Foundation
import NonEmpty


public struct PlacesSummary: Equatable {
  public var places: Set<Place>
  public var requestedAt: Date
  /// A list with 60 elements. First element is the date of requestedAt
  /// Second element is the day before that and so on
  public var driveDistancesForDaysWithVisits: NonEmptyArray<UInt?>

  public init(places: Set<Place>, requestedAt: Date, driveDistancesForDaysWithVisits: NonEmptyArray<UInt?>) { self.places = places; self.requestedAt = requestedAt; self.driveDistancesForDaysWithVisits = driveDistancesForDaysWithVisits }
}
