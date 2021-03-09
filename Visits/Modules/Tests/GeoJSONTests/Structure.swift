import XCTest
@testable import GeoJSON

final class GeoJSONStructureTests: XCTestCase {
  func testDecoding_whenTypeIsInvalid_itThrows() throws {
    AssertThrowsCorrupted(
      decoding: GeoJSON.self,
      from: try fixturePoint.json(updatingKeyPaths: ("type", "Hello World!"))
    )
  }
  
  func testDecoding_whenTypeIsNotAString_itThrows() throws {
    AssertThrowsTypeMismatch(
      decoding: GeoJSON.self,
      from: try fixturePoint.json(updatingKeyPaths: ("type", 50))
    )
  }
  
  func testDecoding_whenCoordinatesIsNotAnArray_itThrows() throws {
    AssertThrowsTypeMismatch(
      decoding: GeoJSON.self,
      from: try fixturePoint.json(updatingKeyPaths: ("coordinates", 50))
    )
    AssertThrowsTypeMismatch(
      decoding: GeoJSON.self,
      from: fixtureNullCoordinates
    )
  }
  
  func testDecoding_whenMissingType_itThrows() throws {
    AssertThrowsKeyNotFound(
      "type",
      decoding: GeoJSON.self,
      from: try fixturePoint.json(deletingKeyPaths: "type")
    )
  }
  
  func testDecoding_whenMissingCoordinates_itThrows() throws {
    AssertThrowsKeyNotFound(
      "coordinates",
      decoding: GeoJSON.self,
      from: try fixturePoint.json(deletingKeyPaths: "coordinates")
    )
  }
}


let fixtureNullCoordinates = Data("""
  {
    "coordinates": null,
    "type": "LineString"
  }
  """.utf8
)
