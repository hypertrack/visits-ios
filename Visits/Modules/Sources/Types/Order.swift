import Foundation
import NonEmpty
import Prelude
import Tagged


public struct Order {
  public var id: ID
  public var createdAt: Date
  public var source: Source
  public var location: Coordinate
  public var geotagSent: Geotag
  public var address: Address
  public var orderNote: OrderNote?
  public var noteFieldFocused: Bool
  public var metadata: [Name: Contents]
  
  public enum Source { case order, trip }
  public enum Geotag {
    public enum Visited {
      case entered(Date)
      case visited(Date, Date)

      public var entered: Date? {
        get {
          guard case let .entered(value) = self else { return nil }
          return value
        }
        set {
          guard case .entered = self, let newValue = newValue else { return }
          self = .entered(newValue)
        }
      }

      public var visited: (Date, Date)? {
        get {
          guard case let .visited(from, to) = self else { return nil }
          return (from, to)
        }
        set {
          guard case .visited = self, let newValue = newValue else { return }
          self = .visited(newValue.0, newValue.1)
        }
      }
    }
    
    case notSent
    case pickedUp
    case entered(Date)
    case visited(Date, Date)
    case checkedOut(Visited?, Date)
    case cancelled(Visited?, Date)

    public var isVisited: Visited? {
      get {
        switch self {
        case .notSent, .pickedUp:
          return nil
        case let .entered(en):
          return .entered(en)
        case let .visited(en, ex):
          return .visited(en, ex)
        case let .cancelled(visited, _),
             let .checkedOut(visited, _):
          return visited
        }
      }
      set {
        switch (self, newValue) {
        case (_, .none): return
        case let (.notSent, .some(.entered(entry))),
             let (.pickedUp, .some(.entered(entry))),
             let (.entered, .some(.entered(entry))),
             let (.visited, .some(.entered(entry))):
          self = .entered(entry)
        case let (.notSent, .some(.visited(entry, exit))),
             let (.pickedUp, .some(.visited(entry, exit))),
             let (.entered, .some(.visited(entry, exit))),
             let (.visited, .some(.visited(entry, exit))):
          self = .visited(entry, exit)
        case let (.checkedOut(_, date), visited):
          self = .checkedOut(visited, date)
        case let (.cancelled(_, date), visited):
          self = .cancelled(visited, date)
        }
      }
    }
    
    public var notSent: Void? {
      guard case .notSent = self else { return nil }
      return ()
    }

    public var pickedUp: Void? {
      guard case .pickedUp = self else { return nil }
      return ()
    }

    public var entered: Date? {
      get {
        guard case let .entered(value) = self else { return nil }
        return value
      }
      set {
        guard case .entered = self, let newValue = newValue else { return }
        self = .entered(newValue)
      }
    }

    public var visited: (Date, Date)? {
      get {
        guard case let .visited(from, to) = self else { return nil }
        return (from, to)
      }
      set {
        guard case .visited = self, let newValue = newValue else { return }
        self = .visited(newValue.0, newValue.1)
      }
    }

    public var checkedOut: (Visited?, Date)? {
      get {
        guard case let .checkedOut(visited, checkedOut) = self else { return nil }
        return (visited, checkedOut)
      }
      set {
        guard case .checkedOut = self, let newValue = newValue else { return }
        self = .checkedOut(newValue.0, newValue.1)
      }
    }

    public var cancelled: (Visited?, Date)? {
      get {
        guard case let .cancelled(visited, canceled) = self else { return nil }
        return (visited, canceled)
      }
      set {
        guard case .cancelled = self, let newValue = newValue else { return }
        self = .cancelled(newValue.0, newValue.1)
      }
    }
  }
  
  public init(
    id: ID,
    createdAt: Date,
    source: Source,
    location: Coordinate,
    geotagSent: Geotag,
    noteFieldFocused: Bool,
    address: Address,
    orderNote: OrderNote? = nil,
    metadata: [Name: Contents] = [:]
  ) {
    self.id = id
    self.createdAt = createdAt
    self.source = source
    self.location = location
    self.geotagSent = geotagSent
    self.noteFieldFocused = noteFieldFocused
    self.address = address
    self.orderNote = orderNote
    self.metadata = metadata
  }
  
  // Newtypes
  public typealias ID             = Tagged<Order,                     NonEmptyString>
  public typealias OrderNote      = Tagged<(Order, orderNote: ()),    NonEmptyString>
  public typealias Name           = Tagged<(Order, name: ()),         NonEmptyString>
  public typealias Contents       = Tagged<(Order, contents: ()),     NonEmptyString>
}

public extension Order {
  static func isFresh(now: Date) -> (Self) -> Bool {
    { (now.addingTimeInterval(-60 * 60 * 24)...now).contains($0.createdAt) }
  }
}

public extension Set where Element == Order {
  static func removeOld(now: Date) -> (Self) -> Self {
    { $0.filter(Order.isFresh(now: now)) }
  }
}

public enum Geotag: Equatable {
  case cancel(Order.ID, Order.Source, Order.OrderNote?)
  case checkOut(Order.ID, Order.Source, Order.OrderNote?)
  case pickUp(Order.ID, Order.Source)
}

public typealias APIOrderID = Tagged<APIOrderIDTag, NonEmptyString>
public enum APIOrderIDTag {}

public struct APIOrder: Equatable {
  public enum Source: Equatable { case order, trip }
  
  public typealias Name     = Tagged<(APIOrder, name: ()),     NonEmptyString>
  public typealias Contents = Tagged<(APIOrder, contents: ()), NonEmptyString>
  
  public let centroid: Coordinate
  public let createdAt: Date
  public let metadata: [Name: Contents]
  public let source: Source
  public let visitStatus: VisitStatus?
  
  public init(
    centroid: Coordinate,
    createdAt: Date,
    metadata: [Name: Contents],
    source: Source,
    visited: VisitStatus?
  ) {
    self.centroid = centroid
    self.createdAt = createdAt
    self.metadata = metadata
    self.source = source
    self.visitStatus = visited
  }
}

public enum VisitStatus: Equatable {
  case entered(Date)
  case visited(Date, Date)
}

// MARK: - Foundation

extension Order: Equatable {}
extension Order: Hashable {}
extension Order: Codable {}

extension Order.Geotag: Equatable {}
extension Order.Geotag: Hashable {}
extension Order.Geotag: AutoCodable {}

extension Order.Geotag.Visited: Equatable {}
extension Order.Geotag.Visited: Hashable {}
extension Order.Geotag.Visited: AutoCodable {}

extension Order.Source: Equatable {}
extension Order.Source: Hashable {}
extension Order.Source: AutoCodable {}
