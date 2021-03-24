import XCTest
@testable import Types


final class GeoJSONPointTests: XCTestCase {
  func testDecoding_whenPoint_itReturnsAPoint() throws {
    XCTAssertEqual(
      .point(Coordinate(latitude: 10, longitude: 30)!),
      try JSONDecoder().decode(GeoJSON.self, from: fixturePoint)
    )
    XCTAssertEqual(
      .point(Coordinate(latitude: 47.855819, longitude: 35.106414)!),
      try JSONDecoder().decode(
        GeoJSON.self,
        from: fixturePoint.json(
          updatingKeyPaths: ("coordinates", [35.106414, 47.855819])
        )
      )
    )
  }
    
  func testDecoding_whenPointHasUnexpectedTypesAfterCoordinates_itIgnoresThem() throws {
    XCTAssertEqual(
      .point(Coordinate(latitude: 10, longitude: 30)!),
      try JSONDecoder().decode(
        GeoJSON.self,
        from: fixturePoint.json(updatingKeyPaths: ("coordinates", [30, 10, "hello", "world", [50]]))
      )
    )
  }
  
  func testDecoding_whenCoordinatesHasLessThenTwoValues_itThrows() throws {
    AssertThrowsValueNotFound(
      decoding: GeoJSON.self,
      from: try fixturePoint.json(updatingKeyPaths: ("coordinates", []))
    )
    AssertThrowsValueNotFound(
      decoding: GeoJSON.self,
      from: try fixturePoint.json(updatingKeyPaths: ("coordinates", [30]))
    )
  }
  
  func testDecoding_whenCoordinatesAreInvalid_itThrows() throws {
    AssertThrowsCorrupted(
      decoding: GeoJSON.self,
      from: try fixturePoint.json(updatingKeyPaths: ("coordinates", [500, 500]))
    )
    AssertThrowsCorrupted(
      decoding: GeoJSON.self,
      from: try fixturePoint.json(updatingKeyPaths: ("coordinates", [180.1, 90]))
    )
  }
  
  func testDecoding_whenCoordinatesAreNotNumbers_itThrows() throws {
    AssertThrowsTypeMismatch(
      decoding: GeoJSON.self,
      from: try fixturePoint.json(updatingKeyPaths: ("coordinates", ["30", "10"]))
    )
  }
}

let point = GeoJSON.point(Coordinate(latitude: 10, longitude: 30)!)
let fixturePoint = Data("""
  {
    "type": "Point",
    "coordinates": [30, 10]
  }
  """.utf8
)
