import Coordinate
import Foundation
import NonEmpty
import Prelude
import Tagged


public typealias Visit = Either<ManualVisit, AssignedVisit>

public enum Visits: Equatable, AutoCodable {
  case mixed(Set<Visit>)
  case assigned(Set<AssignedVisit>)
  case selectedMixed(Visit, Set<Visit>)
  case selectedAssigned(AssignedVisit, Set<AssignedVisit>)

  public var mixed: Set<Visit>? {
    get {
      guard case let .mixed(value) = self else { return nil }
      return value
    }
    set {
      guard case .mixed = self, let newValue = newValue else { return }
      self = .mixed(newValue)
    }
  }

  public var assigned: Set<AssignedVisit>? {
    get {
      guard case let .assigned(value) = self else { return nil }
      return value
    }
    set {
      guard case .assigned = self, let newValue = newValue else { return }
      self = .assigned(newValue)
    }
  }

  public var selectedMixed: (Visit, Set<Visit>)? {
    get {
      guard case let .selectedMixed(visit, set) = self else { return nil }
      return (visit, set)
    }
    set {
      guard case .selectedMixed = self, let newValue = newValue else { return }
      self = .selectedMixed(newValue.0, newValue.1)
    }
  }

  public var selectedAssigned: (AssignedVisit, Set<AssignedVisit>)? {
    get {
      guard case let .selectedAssigned(visit, set) = self else { return nil }
      return (visit, set)
    }
    set {
      guard case .selectedAssigned = self, let newValue = newValue else { return }
      self = .selectedAssigned(newValue.0, newValue.1)
    }
  }
}

public struct ManualVisit {
  public var id: ID
  public var createdAt: Date
  public var geotagSent: Geotag
  public var visitNote: VisitNote?
  public var noteFieldFocused: Bool
  
  public enum Geotag {
    case notSent
    case checkedIn
    case checkedOut(Date)

    public var notSent: Void? {
      guard case .notSent = self else { return nil }
      return ()
    }

    public var checkedIn: Void? {
      guard case .checkedIn = self else { return nil }
      return ()
    }

    public var checkedOut: Date? {
      get {
        guard case let .checkedOut(value) = self else { return nil }
        return value
      }
      set {
        guard case .checkedOut = self, let newValue = newValue else { return }
        self = .checkedOut(newValue)
      }
    }
  }
  
  public init(
    id: ID,
    createdAt: Date,
    geotagSent: Geotag,
    visitNote: VisitNote? = nil,
    noteFieldFocused: Bool
  ) {
    self.id = id
    self.createdAt = createdAt
    self.geotagSent = geotagSent
    self.visitNote = visitNote
    self.noteFieldFocused = noteFieldFocused
  }
  
  // Newtypes
  public typealias ID             = Tagged<ManualVisit,                       NonEmptyString>
  public typealias VisitNote      = Tagged<(ManualVisit, visitNote: ()),      NonEmptyString>
}

public struct AssignedVisit {
  public var id: ID
  public var createdAt: Date
  public var source: Source
  public var location: Coordinate
  public var geotagSent: Geotag
  public var address: These<Street, FullAddress>?
  public var visitNote: VisitNote?
  public var noteFieldFocused: Bool
  public var metadata: [Name: Contents]
  
  public enum Source { case geofence, trip }
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
    address: These<Street, FullAddress>? = nil,
    visitNote: VisitNote? = nil,
    metadata: [Name: Contents] = [:]
  ) {
    self.id = id
    self.createdAt = createdAt
    self.source = source
    self.location = location
    self.geotagSent = geotagSent
    self.noteFieldFocused = noteFieldFocused
    self.address = address
    self.visitNote = visitNote
    self.metadata = metadata
  }
  
  // Newtypes
  public typealias ID             = Tagged<AssignedVisit,                     NonEmptyString>
  public typealias VisitNote      = Tagged<(AssignedVisit, visitNote: ()),    NonEmptyString>
  public typealias Street         = Tagged<(AssignedVisit, street: ()),       NonEmptyString>
  public typealias FullAddress    = Tagged<(AssignedVisit, address: ()),      NonEmptyString>
  public typealias Name           = Tagged<(AssignedVisit, name: ()),         NonEmptyString>
  public typealias Contents       = Tagged<(AssignedVisit, contents: ()),     NonEmptyString>
}

public extension Visits {
  static let assignedLens: Lens<Visits, Set<AssignedVisit>> = .init(
    get: { visits in
      switch visits {
      case let .mixed(vs):
        return Set(vs.compactMap(eitherRight))
      case let .assigned(vs):
        return vs
      case let .selectedMixed(.left, vs):
        return Set(vs.compactMap(eitherRight))
      case let .selectedMixed(.right(v), vs):
        return Set(vs.compactMap(eitherRight) + [v])
      case let .selectedAssigned(v, vs):
        return insert(v, into: vs)
      }
    },
    set: { avs in
      { visits in
        switch visits {
        case let .mixed(vs):
          return .mixed(replace(assigned: avs, inside: vs))
        case let .selectedMixed(.left(m), vs):
          return .selectedMixed(.left(m), replace(assigned: avs, inside: vs))
        case let .selectedMixed(.right(a), vs):
          if let selectedIndex = avs.firstIndex(where: { $0.id == a.id }) {
            var avs = avs
            let newA = avs.remove(at: selectedIndex)
            return .selectedMixed(.right(newA), replace(assigned: avs, inside: vs))
          } else {
            return .mixed(replace(assigned: avs, inside: vs))
          }
        case .assigned:
          return .assigned(avs)
        case let .selectedAssigned(a, vs):
          if let selectedIndex = avs.firstIndex(where: { $0.id == a.id }) {
            var avs = avs
            let newA = avs.remove(at: selectedIndex)
            return .selectedAssigned(newA, avs)
          } else {
            return .assigned(avs)
          }
        }
      }
    }
  )
}

func sameAssignedID(_ id: AssignedVisit.ID) -> (Visit) -> Bool {
  { visit in
    switch visit {
    case .left:
      return false
    case let .right(a) where a.id == id:
      return true
    case .right:
      return false
    }
  }
}

func replace(assigned: Set<AssignedVisit>, inside mixed: Set<Visit>) -> Set<Visit> {
  Set(mixed.compactMap(eitherLeft).map(Visit.left)).union(Set(assigned.map(Visit.right)))
}

public func assignedVisits(from visits: Visits) -> Set<AssignedVisit> {
  let assignedVisits: Set<AssignedVisit>
  switch visits {
  case let .mixed(vs):
    assignedVisits = Set(vs.compactMap(eitherRight))
  case let .assigned(vs):
    assignedVisits = vs
  case let .selectedMixed(.left, vs):
    assignedVisits = Set(vs.compactMap(eitherRight))
  case let .selectedMixed(.right(v), vs):
    assignedVisits = Set(vs.compactMap(eitherRight) + [v])
  case let .selectedAssigned(v, vs):
    assignedVisits = insert(v, into: vs)
  }
  return assignedVisits
}

func insert<Element>(_ newMember: Element, into set: Set<Element>) -> Set<Element> {
  var set = set
  set.insert(newMember)
  return set
}

// MARK: - Foundation

extension ManualVisit: Equatable {}
extension ManualVisit: Hashable {}
extension ManualVisit: Codable {}

extension ManualVisit.Geotag: Equatable {}
extension ManualVisit.Geotag: Hashable {}
extension ManualVisit.Geotag: AutoCodable {}

extension AssignedVisit: Equatable {}
extension AssignedVisit: Hashable {}
extension AssignedVisit: Codable {}

extension AssignedVisit.Geotag: Equatable {}
extension AssignedVisit.Geotag: Hashable {}
extension AssignedVisit.Geotag: AutoCodable {}

extension AssignedVisit.Geotag.Visited: Equatable {}
extension AssignedVisit.Geotag.Visited: Hashable {}
extension AssignedVisit.Geotag.Visited: AutoCodable {}

extension AssignedVisit.Source: Equatable {}
extension AssignedVisit.Source: Hashable {}
extension AssignedVisit.Source: AutoCodable {}
