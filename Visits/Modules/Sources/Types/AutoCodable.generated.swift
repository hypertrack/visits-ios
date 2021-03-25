// Generated using Sourcery 1.3.4 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation

extension Order.Geotag {

    enum CodingKeys: String, CodingKey {
        case notSent
        case pickedUp
        case entered
        case visited
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
        if container.allKeys.contains(.entered), try !container.decodeNil(forKey: .entered) {
            var associatedValues = try container.nestedUnkeyedContainer(forKey: .entered)
            let associatedValue0 = try associatedValues.decode(Date.self)
            self = .entered(associatedValue0)
            return
        }
        if container.allKeys.contains(.visited), try !container.decodeNil(forKey: .visited) {
            var associatedValues = try container.nestedUnkeyedContainer(forKey: .visited)
            let associatedValue0 = try associatedValues.decode(Date.self)
            let associatedValue1 = try associatedValues.decode(Date.self)
            self = .visited(associatedValue0, associatedValue1)
            return
        }
        if container.allKeys.contains(.checkedOut), try !container.decodeNil(forKey: .checkedOut) {
            var associatedValues = try container.nestedUnkeyedContainer(forKey: .checkedOut)
            let associatedValue0 = try associatedValues.decode(Visited?.self)
            let associatedValue1 = try associatedValues.decode(Date.self)
            self = .checkedOut(associatedValue0, associatedValue1)
            return
        }
        if container.allKeys.contains(.cancelled), try !container.decodeNil(forKey: .cancelled) {
            var associatedValues = try container.nestedUnkeyedContainer(forKey: .cancelled)
            let associatedValue0 = try associatedValues.decode(Visited?.self)
            let associatedValue1 = try associatedValues.decode(Date.self)
            self = .cancelled(associatedValue0, associatedValue1)
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
        case let .entered(associatedValue0):
            var associatedValues = container.nestedUnkeyedContainer(forKey: .entered)
            try associatedValues.encode(associatedValue0)
        case let .visited(associatedValue0, associatedValue1):
            var associatedValues = container.nestedUnkeyedContainer(forKey: .visited)
            try associatedValues.encode(associatedValue0)
            try associatedValues.encode(associatedValue1)
        case let .checkedOut(associatedValue0, associatedValue1):
            var associatedValues = container.nestedUnkeyedContainer(forKey: .checkedOut)
            try associatedValues.encode(associatedValue0)
            try associatedValues.encode(associatedValue1)
        case let .cancelled(associatedValue0, associatedValue1):
            var associatedValues = container.nestedUnkeyedContainer(forKey: .cancelled)
            try associatedValues.encode(associatedValue0)
            try associatedValues.encode(associatedValue1)
        }
    }

}

extension Order.Geotag.Visited {

    enum CodingKeys: String, CodingKey {
        case entered
        case visited
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.allKeys.contains(.entered), try !container.decodeNil(forKey: .entered) {
            var associatedValues = try container.nestedUnkeyedContainer(forKey: .entered)
            let associatedValue0 = try associatedValues.decode(Date.self)
            self = .entered(associatedValue0)
            return
        }
        if container.allKeys.contains(.visited), try !container.decodeNil(forKey: .visited) {
            var associatedValues = try container.nestedUnkeyedContainer(forKey: .visited)
            let associatedValue0 = try associatedValues.decode(Date.self)
            let associatedValue1 = try associatedValues.decode(Date.self)
            self = .visited(associatedValue0, associatedValue1)
            return
        }
        throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Unknown enum case"))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let .entered(associatedValue0):
            var associatedValues = container.nestedUnkeyedContainer(forKey: .entered)
            try associatedValues.encode(associatedValue0)
        case let .visited(associatedValue0, associatedValue1):
            var associatedValues = container.nestedUnkeyedContainer(forKey: .visited)
            try associatedValues.encode(associatedValue0)
            try associatedValues.encode(associatedValue1)
        }
    }

}

extension Order.Source {

    enum CodingKeys: String, CodingKey {
        case order
        case trip
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        let enumCase = try container.decode(String.self)
        switch enumCase {
        case CodingKeys.order.rawValue: self = .order
        case CodingKeys.trip.rawValue: self = .trip
        default: throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Unknown enum case '\(enumCase)'"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .order: try container.encode(CodingKeys.order.rawValue)
        case .trip: try container.encode(CodingKeys.trip.rawValue)
        }
    }

}
