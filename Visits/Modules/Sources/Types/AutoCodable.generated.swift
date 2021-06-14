// Generated using Sourcery 1.3.4 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation

extension GeofenceShape {

    enum CodingKeys: String, CodingKey {
        case circle
        case polygon
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.allKeys.contains(.circle), try !container.decodeNil(forKey: .circle) {
            var associatedValues = try container.nestedUnkeyedContainer(forKey: .circle)
            let associatedValue0 = try associatedValues.decode(GeofenceShapeCircle.self)
            self = .circle(associatedValue0)
            return
        }
        if container.allKeys.contains(.polygon), try !container.decodeNil(forKey: .polygon) {
            var associatedValues = try container.nestedUnkeyedContainer(forKey: .polygon)
            let associatedValue0 = try associatedValues.decode(GeofenceShapePolygon.self)
            self = .polygon(associatedValue0)
            return
        }
        throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Unknown enum case"))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let .circle(associatedValue0):
            var associatedValues = container.nestedUnkeyedContainer(forKey: .circle)
            try associatedValues.encode(associatedValue0)
        case let .polygon(associatedValue0):
            var associatedValues = container.nestedUnkeyedContainer(forKey: .polygon)
            try associatedValues.encode(associatedValue0)
        }
    }

}
