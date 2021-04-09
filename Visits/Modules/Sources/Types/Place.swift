import Foundation
import NonEmpty
import Prelude
import Tagged


public struct Place {
  public var id: ID
  public var address: Address
  public var createdAt: CreatedTimestamp
  public var currentlyInside: Entry?
  public var metadata: [Name: Contents] = [:]
  public var shape: GeofenceShape
  public var visits: [Visit]
  
  public struct Visit {
    public var entry: EntryTimestamp
    public var exit: ExitTimestamp
    public var duration: Duration
    public var route: Route?
    
    public init(
      entry: Place.Visit.EntryTimestamp,
      exit: Place.Visit.ExitTimestamp,
      duration: Place.Visit.Duration,
      route: Place.Route? = nil
    ) {
      self.entry = entry
      self.exit = exit
      self.duration = duration
      self.route = route
    }
    
    public typealias Duration          = Tagged<(Visit, duration: ()),  UInt>
    public typealias EntryTimestamp    = Tagged<(Visit, entry: ()),     Date>
    public typealias ExitTimestamp     = Tagged<(Visit, exit: ()),      Date>
  }
  
  public struct Route {
    public var distance: Distance
    public var duration: Duration
    public var idleTime: IdleTime
    
    public init(
      distance: Place.Route.Distance,
      duration: Place.Route.Duration,
      idleTime: Place.Route.IdleTime
    ) {
      self.distance = distance
      self.duration = duration
      self.idleTime = idleTime
    }
    
    public typealias Distance          = Tagged<(Route, distance: ()),  UInt>
    public typealias Duration          = Tagged<(Route, duration: ()),  UInt>
    public typealias IdleTime          = Tagged<(Route, idleTime: ()),  UInt>
  }
  
  public struct Entry {
    public var entry: EntryTimestamp
    public var duration: Duration
    public var route: Route?
    
    public init(
      entry: Place.Entry.EntryTimestamp,
      duration: Place.Entry.Duration,
      route: Place.Route? = nil
    ) {
      self.entry = entry
      self.duration = duration
      self.route = route
    }
    
    public typealias EntryTimestamp    = Tagged<(Entry, entry: ()),     Date>
    public typealias Duration          = Tagged<(Entry, duration: ()),  UInt>
  }
  
  public init(
    id: Place.ID,
    address: Address,
    createdAt: Place.CreatedTimestamp,
    currentlyInside: Place.Entry? = nil,
    metadata: [Place.Name : Place.Contents] = [:],
    shape: GeofenceShape,
    visits: [Place.Visit]
  ) {
    self.id = id
    self.address = address
    self.createdAt = createdAt
    self.currentlyInside = currentlyInside
    self.metadata = metadata
    self.shape = shape
    self.visits = visits
  }
  
  public typealias ID                  = Tagged<(Place, id: ()),        NonEmptyString>
  public typealias CreatedTimestamp    = Tagged<(Place, createdAt: ()), Date>
  public typealias Name                = Tagged<(Place, name: ()),      NonEmptyString>
  public typealias Contents            = Tagged<(Place, contents: ()),  NonEmptyString>
}


extension Place: Equatable {}
extension Place.Visit: Equatable {}
extension Place.Route: Equatable {}
extension Place.Entry: Equatable {}

extension Place: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

extension Place.Visit: Codable {}
extension Place.Route: Codable {}
extension Place.Entry: Codable {}
extension Place: Codable {}
