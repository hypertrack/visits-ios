import Foundation
import NonEmpty
import Tagged
import Utility

public struct PlaceVisit: Equatable, Hashable {
  public var address: NonEmptyString?
  public var duration: UInt
  public var entry: EntryTimestamp
  public var exit: ExitTimestamp?
  public var id: ID
  public var integration: IntegrationEntity?
  public var name: NonEmptyString? {
    address
  }
  public var route: Place.Route?

  public init(
    address: NonEmptyString?,
    duration: UInt,
    entry: EntryTimestamp,
    exit: ExitTimestamp?,
    id: ID,
    integration: IntegrationEntity? = nil,
    route: Place.Route? = nil
  ) {
    self.address = address
    self.duration = duration
    self.entry = entry
    self.exit = exit
    self.id = id
    self.integration = integration
    self.route = route
  }

  public typealias ID = Tagged<(PlaceVisit, id: ()), NonEmptyString>
  public typealias EntryTimestamp = Tagged<(PlaceVisit, entry: ()), Date>
  public typealias ExitTimestamp = Tagged<(PlaceVisit, exit: ()), Date>
}
