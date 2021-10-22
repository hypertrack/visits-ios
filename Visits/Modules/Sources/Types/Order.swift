import Foundation
import NonEmpty
import Utility
import Tagged


public struct Order {
  public var id: ID
  public var createdAt: Date
  public var location: Coordinate
  public var address: Address
  public var status: Status
  public var note: Note?
  public var visited: Visited?
  public var metadata: [Name: Contents]
  
  public enum Status {
    case ongoing(NoteFocus)
    case completing
    case completed(Date)
    case cancelling
    case cancelled
    case snoozing
    case snoozed
    case unsnoozing
    
    public enum NoteFocus { case focused, unfocused }
  }
  
  public enum Visited {
    case entered(Date)
    case visited(Date, Date)
  }
  
  public init(
    id: ID,
    createdAt: Date,
    location: Coordinate,
    address: Address,
    status: Status,
    note: Note? = nil,
    visited: Visited? = nil,
    metadata: [Name: Contents] = [:]
  ) {
    self.id = id
    self.createdAt = createdAt
    self.location = location
    self.address = address
    self.status = status
    self.note = note
    self.visited = visited
    self.metadata = metadata
  }
  
  // Newtypes
  public typealias ID       = Tagged<(Order, id: ()),       NonEmptyString>
  public typealias TripID   = Tagged<(Order, tripID: ()),   NonEmptyString>
  public typealias Note     = Tagged<(Order, note: ()),     NonEmptyString>
  public typealias Name     = Tagged<(Order, name: ()),     NonEmptyString>
  public typealias Contents = Tagged<(Order, contents: ()), NonEmptyString>
}

public enum VisitStatus: Equatable {
  case entered(Date)
  case visited(Date, Date)
}

// MARK: - Convenience

extension Order.Visited {
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

public extension Order {
  var title: NonEmptyString {
    switch self.address.anyAddressStreetBias {
    case     .none:    return "Order @ \(DateFormatter.stringTime(self.createdAt))"
    case let .some(a): return a
    }
  }
  
  var name: NonEmptyString? {
    return metadata["name"]?.rawValue
  }

}

// MARK: - Foundation

extension Order: Equatable {}
extension Order: Hashable {}

extension Order.Status: Equatable {}
extension Order.Status: Hashable {}

extension Order.Visited: Equatable {}
extension Order.Visited: Hashable {}

extension Order.Status.NoteFocus: Equatable {}
extension Order.Status.NoteFocus: Hashable {}

extension Order: Identifiable {}
