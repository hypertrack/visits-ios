import NonEmpty
import XCTest
@testable import Types


final class GeoJSONLineStringTests: XCTestCase {
  func testDecoding_whenLineStringCoordinates_itReturnsLineStringCoordinates() throws {
    XCTAssertEqual(
      lineStringCoordinates,
      try JSONDecoder().decode(GeoJSON.self, from: fixtureLineStringCoordinates)
    )
  }
    
  func testDecoding_whenLineStringLocations_itReturnsLineStringLocations() throws {
    XCTAssertEqual(
      lineStringLocations,
      try JSONDecoder().decode(GeoJSON.self, from: fixtureLineStringLocations)
    )
  }
  
  func testDecoding_whenLineStringLocationsThirdParameterIsNotANumber_itIgnoresIt() throws {
    XCTAssertEqual(
      GeoJSON.lineString(.right(NonEmptyArray(rawValue: [location1])!)),
      try JSONDecoder().decode(
        GeoJSON.self,
        from: fixtureLineStringCoordinates.json(
          updatingKeyPaths: (
            "coordinates",
            [
              [77.592203, 12.92254, [], "2020-08-16T11:05:20.786Z"]
            ]
          )
        )
      )
    )
  }
  
  func testDecoding_whenEmpty_itReturnsLineStringNil() throws {
    XCTAssertEqual(
      GeoJSON.lineString(nil),
      try JSONDecoder().decode(
        GeoJSON.self,
        from: fixtureLineStringCoordinates.json(updatingKeyPaths: ("coordinates", []))
      )
    )
  }
  
  func testDecoding_whenFourthMemberIsNotAString_itThrows() throws {
    AssertThrowsTypeMismatch(
      decoding: GeoJSON.self,
      from: try fixtureLineStringCoordinates.json(updatingKeyPaths: ("coordinates", [[10, 10, 10, 10]]))
    )
  }
  
  func testDecoding_whenCoordinatesLineStringHasLessThenTwoValues_itThrows() throws {
    AssertThrowsValueNotFound(
      decoding: GeoJSON.self,
      from: try fixtureLineStringCoordinates.json(updatingKeyPaths: ("coordinates", [[]]))
    )
    AssertThrowsValueNotFound(
      decoding: GeoJSON.self,
      from: try fixtureLineStringCoordinates.json(updatingKeyPaths: ("coordinates", [[30]]))
    )
  }
  
  func testDecoding_whenCoordinatesLineStringAreInvalid_itThrows() throws {
    AssertThrowsCorrupted(
      decoding: GeoJSON.self,
      from: try fixtureLineStringCoordinates.json(updatingKeyPaths: ("coordinates", [[500, 500]]))
    )
    AssertThrowsCorrupted(
      decoding: GeoJSON.self,
      from: try fixtureLineStringCoordinates.json(updatingKeyPaths: ("coordinates", [[180.1, 90]]))
    )
  }
  
  func testDecoding_whenLineStringCoordinatesAreNotNumbers_itThrows() throws {
    AssertThrowsTypeMismatch(
      decoding: GeoJSON.self,
      from: try fixtureLineStringCoordinates.json(updatingKeyPaths: ("coordinates", [["30", "10"]]))
    )
  }
  
  func testDecoding_whenLineStringCoordinateDateIsInvalid_itThrows() throws {
    AssertThrowsCorrupted(
      decoding: GeoJSON.self,
      from: try fixtureLineStringCoordinates.json(updatingKeyPaths: ("coordinates", [[
        77.592203,
        12.92254,
        844.0,
        "2020-08-16 11:05:20"
      ]]))
    )
  }
}

let coordinate1 = Coordinate(latitude: 12.92254, longitude: 77.592203)!
let location1 = Location(
  coordinate: coordinate1,
  recordedAt: "2020-08-16T11:05:20.786Z".iso8601!
)
let coordinate2 = Coordinate(latitude: 12.922758, longitude: 77.592245)!
let location2 = Location(
  coordinate: coordinate2,
  recordedAt: "2020-08-16T11:05:53.282Z".iso8601!
)
let coordinate3 = Coordinate(latitude: 12.922758, longitude: 77.592245)!
let location3 = Location(
  coordinate: coordinate3,
  recordedAt: "2020-08-16T11:06:28.673Z".iso8601!
)
let coordinate4 = Coordinate(latitude: 12.922818, longitude: 77.592284)!
let location4 = Location(
  coordinate: coordinate4,
  recordedAt: "2020-08-16T11:08:35.460Z".iso8601!
)

let lineStringCoordinates = GeoJSON.lineString(.left(NonEmptyArray(rawValue: [coordinate1, coordinate2, coordinate3, coordinate4])!))
let lineStringLocations = GeoJSON.lineString(.right(NonEmptyArray(rawValue: [location1, location2, location3, location4])!))

let fixtureLineStringCoordinates = Data("""
  {
    "coordinates": [
      [
        77.592203,
        12.92254
      ],
      [
        77.592245,
        12.922758
      ],
      [
        77.592245,
        12.922758
      ],
      [
        77.592284,
        12.922818
      ]
    ],
    "type": "LineString"
  }
  """.utf8
)

let fixtureLineStringLocations = Data("""
  {
    "coordinates": [
      [
        77.592203,
        12.92254,
        844.0,
        "2020-08-16T11:05:20.786Z"
      ],
      [
        77.592245,
        12.922758,
        844.0,
        "2020-08-16T11:05:53.282Z"
      ],
      [
        77.592245,
        12.922758,
        844.0,
        "2020-08-16T11:06:28.673Z"
      ],
      [
        77.592284,
        12.922818,
        844.0,
        "2020-08-16T11:08:35.460Z"
      ]
    ],
    "type": "LineString"
  }
  """.utf8
)
