// Generated using Sourcery 1.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation

extension AssignedVisit.Geotag {

    enum CodingKeys: String, CodingKey {
        case notSent
        case pickedUp
        case checkedIn
        case checkedOut
        case cancelled
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.allKeys.contains(.notSent), try !container.decodeNil(forKey: .notSent) {
            self = .notSent
            return
        }
        if container.allKeys.contains(.pickedUp), try !container.decodeNil(forKey: .pickedUp) {
            self = .pickedUp
            return
        }
        if container.allKeys.contains(.checkedIn), try !container.decodeNil(forKey: .checkedIn) {
            self = .checkedIn
            return
        }
        if container.allKeys.contains(.checkedOut), try !container.decodeNil(forKey: .checkedOut) {
            var associatedValues = try container.nestedUnkeyedContainer(forKey: .checkedOut)
            let associatedValue0 = try associatedValues.decode(Date.self)
            self = .checkedOut(associatedValue0)
            return
        }
        if container.allKeys.contains(.cancelled), try !container.decodeNil(forKey: .cancelled) {
            var associatedValues = try container.nestedUnkeyedContainer(forKey: .cancelled)
            let associatedValue0 = try associatedValues.decode(Date.self)
            self = .cancelled(associatedValue0)
            return
        }
        throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Unknown enum case"))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .notSent:
            _ = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .notSent)
        case .pickedUp:
            _ = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .pickedUp)
        case .checkedIn:
            _ = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .checkedIn)
        case let .checkedOut(associatedValue0):
            var associatedValues = container.nestedUnkeyedContainer(forKey: .checkedOut)
            try associatedValues.encode(associatedValue0)
        case let .cancelled(associatedValue0):
            var associatedValues = container.nestedUnkeyedContainer(forKey: .cancelled)
            try associatedValues.encode(associatedValue0)
        }
    }

}

extension AssignedVisit.Source {

    enum CodingKeys: String, CodingKey {
        case geofence
        case trip
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        let enumCase = try container.decode(String.self)
        switch enumCase {
        case CodingKeys.geofence.rawValue: self = .geofence
        case CodingKeys.trip.rawValue: self = .trip
        default: throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Unknown enum case '\(enumCase)'"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .geofence: try container.encode(CodingKeys.geofence.rawValue)
        case .trip: try container.encode(CodingKeys.trip.rawValue)
        }
    }

}

extension ManualVisit.Geotag {

    enum CodingKeys: String, CodingKey {
        case notSent
        case checkedIn
        case checkedOut
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.allKeys.contains(.notSent), try !container.decodeNil(forKey: .notSent) {
            self = .notSent
            return
        }
        if container.allKeys.contains(.checkedIn), try !container.decodeNil(forKey: .checkedIn) {
            self = .checkedIn
            return
        }
        if container.allKeys.contains(.checkedOut), try !container.decodeNil(forKey: .checkedOut) {
            var associatedValues = try container.nestedUnkeyedContainer(forKey: .checkedOut)
            let associatedValue0 = try associatedValues.decode(Date.self)
            self = .checkedOut(associatedValue0)
            return
        }
        throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Unknown enum case"))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .notSent:
            _ = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .notSent)
        case .checkedIn:
            _ = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .checkedIn)
        case let .checkedOut(associatedValue0):
            var associatedValues = container.nestedUnkeyedContainer(forKey: .checkedOut)
            try associatedValues.encode(associatedValue0)
        }
    }

}

extension Visits {

    enum CodingKeys: String, CodingKey {
        case mixed
        case assigned
        case selectedMixed
        case selectedAssigned
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.allKeys.contains(.mixed), try !container.decodeNil(forKey: .mixed) {
            var associatedValues = try container.nestedUnkeyedContainer(forKey: .mixed)
            let associatedValue0 = try associatedValues.decode(Set<Visit>.self)
            self = .mixed(associatedValue0)
            return
        }
        if container.allKeys.contains(.assigned), try !container.decodeNil(forKey: .assigned) {
            var associatedValues = try container.nestedUnkeyedContainer(forKey: .assigned)
            let associatedValue0 = try associatedValues.decode(Set<AssignedVisit>.self)
            self = .assigned(associatedValue0)
            return
        }
        if container.allKeys.contains(.selectedMixed), try !container.decodeNil(forKey: .selectedMixed) {
            var associatedValues = try container.nestedUnkeyedContainer(forKey: .selectedMixed)
            let associatedValue0 = try associatedValues.decode(Visit.self)
            let associatedValue1 = try associatedValues.decode(Set<Visit>.self)
            self = .selectedMixed(associatedValue0, associatedValue1)
            return
        }
        if container.allKeys.contains(.selectedAssigned), try !container.decodeNil(forKey: .selectedAssigned) {
            var associatedValues = try container.nestedUnkeyedContainer(forKey: .selectedAssigned)
            let associatedValue0 = try associatedValues.decode(AssignedVisit.self)
            let associatedValue1 = try associatedValues.decode(Set<AssignedVisit>.self)
            self = .selectedAssigned(associatedValue0, associatedValue1)
            return
        }
        throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Unknown enum case"))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let .mixed(associatedValue0):
            var associatedValues = container.nestedUnkeyedContainer(forKey: .mixed)
            try associatedValues.encode(associatedValue0)
        case let .assigned(associatedValue0):
            var associatedValues = container.nestedUnkeyedContainer(forKey: .assigned)
            try associatedValues.encode(associatedValue0)
        case let .selectedMixed(associatedValue0, associatedValue1):
            var associatedValues = container.nestedUnkeyedContainer(forKey: .selectedMixed)
            try associatedValues.encode(associatedValue0)
            try associatedValues.encode(associatedValue1)
        case let .selectedAssigned(associatedValue0, associatedValue1):
            var associatedValues = container.nestedUnkeyedContainer(forKey: .selectedAssigned)
            try associatedValues.encode(associatedValue0)
            try associatedValues.encode(associatedValue1)
        }
    }

}
