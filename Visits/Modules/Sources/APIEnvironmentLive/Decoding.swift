import CoreLocation
import Foundation
import GLKit
import NonEmpty
import Types


let snakeCaseDecoder: JSONDecoder = {
  let decoder = JSONDecoder()
  decoder.keyDecodingStrategy = .convertFromSnakeCase
  return decoder
}()

struct DynamicKey: CodingKey {
  var intValue: Int?
  var stringValue: String
  
  init?(intValue: Int) {
    self.intValue = intValue
    self.stringValue = "\(intValue)"
  }
  init?(stringValue: String) {
    self.stringValue = stringValue
  }
}

func decodeGeofenceShape<CodingKey>(
  radius: UInt?,
  decoder: Decoder,
  container: KeyedDecodingContainer<CodingKey>,
  key: CodingKey
) throws -> GeofenceShape {
  let geometryGeoJSON = try container.decode(GeoJSON.self, forKey: key)
  switch geometryGeoJSON {
  case let .point(coordinate):
    if let radius = radius {
      return .circle(.init(center: coordinate, radius: radius))
    } else {
      throw DecodingError.dataCorrupted(
        DecodingError.Context(
          codingPath: decoder.codingPath,
          debugDescription: "No radius for a circular geofence"
        )
      )
    }
  case let .polygon(polygon):
    return .polygon(.init(centroid: centroid(from: polygon), polygon: polygon))
  case .lineString:
    throw DecodingError.dataCorrupted(
      DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: "Expected Polygon or Point, but got LineString"
      )
    )
  }
}

func decodeGeofenceCentroid<CodingKey>(
  decoder: Decoder,
  container: KeyedDecodingContainer<CodingKey>,
  key: CodingKey
) throws -> Coordinate {
  let geometryGeoJSON = try container.decode(GeoJSON.self, forKey: key)
  switch geometryGeoJSON {
  case let .point(coordinate):  return coordinate
  case let .polygon(polygon):   return centroid(from: polygon)
  case .lineString:
    throw DecodingError.dataCorrupted(
      DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: "Expected Polygon or Point, but got LineString"
      )
    )
  }
}

func centroid(from linearRings: NonEmptyArray<LinearRing>) -> Coordinate {
  let points = linearRings.flatMap { [$0.origin] + [$0.first] + [$0.second] + $0.rest }
  
  var x:Float = 0.0
  var y:Float = 0.0
  var z:Float = 0.0
  for point in points {
    let lat = GLKMathDegreesToRadians(Float(point.latitude))
    let long = GLKMathDegreesToRadians(Float(point.longitude))
    
    x += cos(lat) * cos(long)
    
    y += cos(lat) * sin(long)
    
    z += sin(lat)
  }
  x = x / Float(points.count)
  y = y / Float(points.count)
  z = z / Float(points.count)
  let resultLong = atan2(y, x)
  let resultHyp = sqrt(x * x + y * y)
  let resultLat = atan2(z, resultHyp)
  let result = Coordinate(
    latitude: CLLocationDegrees(GLKMathRadiansToDegrees(Float(resultLat))),
    longitude: CLLocationDegrees(GLKMathRadiansToDegrees(Float(resultLong)))
  )
  return result!
}

func decodeTimestamp<CodingKey>(
  decoder: Decoder,
  container: KeyedDecodingContainer<CodingKey>,
  key: CodingKey
) throws -> Date {
  let dateISO8601 = try container.decode(NonEmptyString.self, forKey: key)
  guard let date = dateISO8601.iso8601 else {
    let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "created_at does not conform to ISO8601 format")
    throw DecodingError.dataCorrupted(context)
  }
  return date
}

func decodeMetadata<CodingKey>(
  decoder: Decoder,
  container: KeyedDecodingContainer<CodingKey>,
  key: CodingKey
) throws -> NonEmptyDictionary<NonEmptyString, NonEmptyString>? {
  if let metadataContainer = try? container.nestedContainer(keyedBy: DynamicKey.self, forKey: key) {
    var mutMetadata: [NonEmptyString: NonEmptyString] = [:]
    for key in metadataContainer.allKeys {
      guard !key.stringValue.hasPrefix("ht_") else { continue }
      
      if let value = try? metadataContainer.decodeIfPresent(String.self, forKey: key),
         let nonEmptyKey = NonEmptyString(rawValue: key.stringValue),
         let nonEmptyValue = NonEmptyString(rawValue: value) {
        mutMetadata[nonEmptyKey] = nonEmptyValue
      }
    }
    return NonEmptyDictionary(rawValue: mutMetadata)
  } else {
    return nil
  }
}
