import Foundation
import NonEmpty
import Prelude


public enum GeoJSON {
  case point(Coordinate)
  case lineString(Either<NonEmptyArray<Coordinate>, NonEmptyArray<Location>>?)
  case polygon(NonEmptyArray<LinearRing>)
}

public struct Location {
  public let coordinate: Coordinate
  public let recordedAt: Date
}

public struct LinearRing {
  public let origin: Coordinate
  public let first: Coordinate
  public let second: Coordinate
  public let rest: [Coordinate]
}

// MARK: - Equatable

extension GeoJSON: Equatable {}
extension Location: Equatable {}
extension LinearRing: Equatable {}

// MARK: - Decodable

extension GeoJSON: Decodable {
  enum CodingKeys: String, CodingKey {
    case type
    case coordinates
  }
  
  enum GeometryType: String, Decodable {
    case point = "Point"
    case lineString = "LineString"
    case polygon = "Polygon"
  }
  
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    let type = try values.decode(GeometryType.self, forKey: .type)
    var coordinatesJSON = try values.nestedUnkeyedContainer(forKey: .coordinates)
    switch type {
    case .point:
      self = .point(try decodeCoordinate(decoder: decoder, container: &coordinatesJSON))
    case .lineString:
      if coordinatesJSON.isAtEnd {
        self = .lineString(nil)
      } else {
        var firstContainer = try coordinatesJSON.nestedUnkeyedContainer()
        
        if let count = firstContainer.count, count >= 4 {
          let head = try decodeLocation(decoder: decoder, container: &firstContainer)
          var tail: [Location] = []
          
          while !coordinatesJSON.isAtEnd {
            var next = try coordinatesJSON.nestedUnkeyedContainer()
            tail.append(try decodeLocation(decoder: decoder, container: &next))
          }
          self = .lineString(.right(NonEmptyArray(rawValue: [head] + tail)!))
        } else {
          let head = try decodeCoordinate(decoder: decoder, container: &firstContainer)
          var tail: [Coordinate] = []
          
          while !coordinatesJSON.isAtEnd {
            var next = try coordinatesJSON.nestedUnkeyedContainer()
            tail.append(try decodeCoordinate(decoder: decoder, container: &next))
          }
          self = .lineString(.left(NonEmptyArray(rawValue: [head] + tail)!))
        }
      }
    case .polygon:
      var linearRings: [LinearRing] = []
      
      while !coordinatesJSON.isAtEnd {
        var linearRingContainer = try coordinatesJSON.nestedUnkeyedContainer()
        var linearRingCoordinates: [Coordinate] = []
        while !linearRingContainer.isAtEnd {
          var nestedCoordinatesJSON = try linearRingContainer.nestedUnkeyedContainer()
          linearRingCoordinates.append(try decodeCoordinate(decoder: decoder, container: &nestedCoordinatesJSON))
        }
        guard linearRingCoordinates.count >= 4,
              let startCoordinate = linearRingCoordinates.first,
              let endCoordinate = linearRingCoordinates.last,
              startCoordinate == endCoordinate,
              let firstCoordinate = linearRingCoordinates.dropFirst().first,
              let secondCoordinate = linearRingCoordinates.dropFirst().dropFirst().first
        else {
          throw DecodingError.dataCorrupted(
            .init(
              codingPath: decoder.codingPath,
              debugDescription: "There are not enough coordinates to calculate a Polygon or first and last coordinates are not equal"
            )
          )
        }
        linearRings.append(
          LinearRing(
            origin: startCoordinate,
            first: firstCoordinate,
            second: secondCoordinate,
            rest: Array(
              linearRingCoordinates.dropFirst().dropFirst().dropFirst().dropLast()
            )
          )
        )
      }
      
      guard let nonEmptyLinearRings = NonEmptyArray(rawValue: linearRings) else {
        throw DecodingError.dataCorrupted(
          .init(
            codingPath: decoder.codingPath,
            debugDescription: "Polygon couldn't be empty"
          )
        )
      }
      self = .polygon(nonEmptyLinearRings)
    }
  }
}


func decodeCoordinate(decoder: Decoder, container: inout UnkeyedDecodingContainer) throws -> Coordinate {
  let longitude = try container.decode(Double.self)
  let latitude = try container.decode(Double.self)
  
  guard let coordinate = Coordinate(latitude: latitude, longitude: longitude) else {
    throw DecodingError.dataCorrupted(
      .init(
        codingPath: decoder.codingPath,
        debugDescription: "lat: \(latitude) lon: \(longitude) don't form a valid coordinate"
      )
    )
  }
  return coordinate
}

func decodeLocation(decoder: Decoder, container: inout UnkeyedDecodingContainer) throws -> Location {
  let coordinate = try decodeCoordinate(decoder: decoder, container: &container)
  
  try container.skip()
  
  let dateISO8601 = try container.decode(NonEmptyString.self)
  guard let date = dateISO8601.iso8601 else {
    throw DecodingError.dataCorrupted(
      .init(
        codingPath: decoder.codingPath,
        debugDescription: "\(dateISO8601.rawValue) does not conform to ISO8601 format")
    )
  }
  return Location(coordinate: coordinate, recordedAt: date)
}

// From: https://github.com/apple/swift/pull/23707
// Default implementation of skip() in terms of decoding an empty struct
struct Empty: Decodable { }
extension UnkeyedDecodingContainer {
  public mutating func skip() throws {
    _ = try decode(Empty.self)
  }
}
