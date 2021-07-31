import XCTest
@testable import Utility


final class JSONTests: XCTestCase {
  func testNull() {
    assert(json: nil, equals: "null")
  }
  
  func testThrowsWhenInvalid() {
    AssertThrowsCorrupted(decoding: JSON.self, from: "nul".data(using: .utf8)!)
  }
  
  func testInteger() {
    assert(json: 42, equals: "42")
  }
  
  func testDecodingNumberFromFractional() {
    assert(json: 42.100000000000001, equals: "42.100000000000001")
  }
  
  func testDecodingString() {
    assert(json: "test", equals: #""test""#)
  }
  
  func testDecodingBoolean() {
    assert(json: true, equals: "true")
  }
  
  func testDecodingEmptyObject() {
    assert(json: [:], equals: "{}")
  }
  
  func testDecodingObjectWithOneKeyValueString() {
    assert(
      json: ["key": "value"],
      equals: #"{"key":"value"}"#
    )
  }
  
  func testDecodingObjectWithNestedArrayOfNumbers() {
    assert(
      json: ["key": [42]],
      equals: #"{"key":[42]}"#
    )
  }
  
  func testDecodingObjectWithNullValue() {
    assert(
      json: ["key": nil],
      equals: #"{"key":null}"#
    )
  }
  
  func testDecodingNestedObjects() {
    assert(
      json: ["key": ["key": ["key": [:]]]],
      equals: #"{"key":{"key":{"key":{}}}}"#
    )
  }
  
  func testDecodingEmptyArray() {
    assert(json: [], equals: "[]")
  }
  
  func testDecodingArrayOfMixedItems() {
    assert(
      json: [nil, false, 42, "test", [:], []],
      equals: #"[null,false,42,"test",{},[]]"#
    )
  }
  
  func testDecodingNestedArrays() {
    assert(
      json: [[[[]]]],
      equals: "[[[[]]]]"
    )
  }
}


func assert(json j: JSON, equals s: String, file: StaticString = #filePath, line: UInt = #line) {
  XCTAssertEqual(j, try decodeJSON(from: s), file: file, line: line)
  XCTAssertEqual(s, try encodeJSON(from: j), file: file, line: line)
}

func decodeJSON(from string: String) throws -> JSON {
  try JSONDecoder().decode(JSON.self, from: string.data(using: .utf8)!)
}

func encodeJSON(from json: JSON) throws -> String {
  String(data: try JSONEncoder().encode(json), encoding: .utf8)!
}
