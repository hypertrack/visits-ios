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
  public typealias VisitNote   = Tagged<(ManualVisit, visitNote: ()),   NonEmptyString>
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
  public var metadata: NonEmptyDictionary<Name, Contents>?
  
  public enum Source { case geofence, trip }
  public enum Geotag {
    case notSent, pickedUp, checkedIn, checkedOut(Date), cancelled(Date)
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
    metadata: NonEmptyDictionary<Name, Contents>? = nil
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
  public typealias VisitNote   = Tagged<(AssignedVisit, visitNote: ()), NonEmptyString>
  public typealias Street         = Tagged<(AssignedVisit, street: ()),       NonEmptyString>
  public typealias FullAddress    = Tagged<(AssignedVisit, address: ()),      NonEmptyString>
  public typealias Name           = Tagged<(AssignedVisit, name: ()),         NonEmptyString>
  public typealias Contents       = Tagged<(AssignedVisit, contents: ()),     NonEmptyString>
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

extension AssignedVisit.Source: Equatable {}
extension AssignedVisit.Source: Hashable {}
extension AssignedVisit.Source: AutoCodable {}
