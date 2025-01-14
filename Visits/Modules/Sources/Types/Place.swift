import Foundation
import NonEmpty
import Utility
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
    public var id: ID
    public var entry: EntryTimestamp
    public var exit: ExitTimestamp
    public var route: Route?
    
    public init(
      id: ID,
      entry: EntryTimestamp,
      exit: ExitTimestamp,
      route: Route? = nil
    ) {
      self.id = id
      self.entry = entry
      self.exit = exit
      self.route = route
    }
    
    public typealias ID                = Tagged<(Visit, id: ()),        NonEmptyString>
    public typealias EntryTimestamp    = Tagged<(Visit, entry: ()),     Date>
    public typealias ExitTimestamp     = Tagged<(Visit, exit: ()),      Date>
  }
  
  public struct Route: Hashable {
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
    public var id: ID
    public var entry: EntryTimestamp
    public var route: Route?
    
    public init(
      id: ID,
      entry: EntryTimestamp,
      route: Place.Route? = nil
    ) {
      self.id = id
      self.entry = entry
      self.route = route
    }
    
    public typealias ID                = Tagged<(Entry, id: ()),        NonEmptyString>
    public typealias EntryTimestamp    = Tagged<(Entry, entry: ()),     Date>
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


extension Place: Identifiable {}
extension Place.Visit: Identifiable {}

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

public extension Place {
  var visited: Bool { currentlyInside != nil || !visits.isEmpty }
  
  var title: NonEmptyString {
    name ?? address.anyAddressStreetBias ?? fallbackTitle
  }
  
  var name: NonEmptyString? {
    if let name = metadata["name"] {
      return name.rawValue
    }
    if let nameKey = metadata.keys.first(where: { $0.string.contains("name") }),
       let name = metadata[nameKey]  {
      return name.rawValue
    }
    return nil
  }
  
  var fallbackTitle: NonEmptyString {
    if Calendar.current.isDate(createdAt.rawValue, equalTo: Date(), toGranularity: .day) {
      return "Place created @ \(DateFormatter.stringTime(createdAt.rawValue))"
    } else {
      return "Place created @ \(DateFormatter.stringDate(createdAt.rawValue)), \(DateFormatter.stringTime(createdAt.rawValue))"
    }
  }
  
  var numberOfVisits: UInt {
    switch currentlyInside {
    case .some: return UInt(1 + visits.count)
    case .none: return UInt(visits.count)
    }
  }
}
