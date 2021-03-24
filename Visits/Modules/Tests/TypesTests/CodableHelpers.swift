import XCTest

// Credit goes to Paul Samuels: https://paul-samuels.com/blog/2019/01/07/swift-codable-testing/


func AssertThrowsKeyNotFound<T: Decodable>(_ expectedKey: String, decoding: T.Type, from data: Data, file: StaticString = #file, line: UInt = #line) {
  XCTAssertThrowsError(try JSONDecoder().decode(decoding, from: data), file: file, line: line) { error in
    if case .keyNotFound(let key, _) = error as? DecodingError {
      XCTAssertEqual(expectedKey, key.stringValue, "Expected missing key '\(key.stringValue)' to equal '\(expectedKey)'.", file: file, line: line)
    } else {
      XCTFail("Expected '.keyNotFound(\(expectedKey))' but got \(error)", file: file, line: line)
    }
  }
}

func AssertThrowsTypeMismatch<T: Decodable>(decoding: T.Type, from data: Data, file: StaticString = #file, line: UInt = #line) {
  XCTAssertThrowsError(try JSONDecoder().decode(decoding, from: data), file: file, line: line) { error in
    if case .typeMismatch = error as? DecodingError {
      XCTAssertTrue(true)
    } else {
      XCTFail("Expected '.typeMismatch' but got \(error)", file: file, line: line)
    }
  }
}

func AssertThrowsValueNotFound<T: Decodable>(decoding: T.Type, from data: Data, file: StaticString = #file, line: UInt = #line) {
  XCTAssertThrowsError(try JSONDecoder().decode(decoding, from: data), file: file, line: line) { error in
    if case .valueNotFound = error as? DecodingError {
      XCTAssertTrue(true)
    } else {
      XCTFail("Expected '.valueNotFound' but got \(error)", file: file, line: line)
    }
  }
}

func AssertThrowsCorrupted<T: Decodable>(decoding: T.Type, from data: Data, file: StaticString = #file, line: UInt = #line) {
  XCTAssertThrowsError(try JSONDecoder().decode(decoding, from: data), file: file, line: line) { error in
    if case .dataCorrupted = error as? DecodingError {
      XCTAssertTrue(true)
    } else {
      XCTFail("Expected '.dataCorrupted' but got \(error)", file: file, line: line)
    }
  }
}

extension Data {
  func json(updatingKeyPaths keyPaths: (String, Any)...) throws -> Data {
    let decoded = try JSONSerialization.jsonObject(with: self, options: .mutableContainers) as AnyObject
    
    for (keyPath, value) in keyPaths {
      decoded.setValue(value, forKeyPath: keyPath)
    }
    
    return try JSONSerialization.data(withJSONObject: decoded)
  }
  
  func json(deletingKeyPaths keyPaths: String...) throws -> Data {
    let decoded = try JSONSerialization.jsonObject(with: self, options: .mutableContainers) as AnyObject
    
    for keyPath in keyPaths {
      decoded.setValue(nil, forKeyPath: keyPath)
    }
    
    return try JSONSerialization.data(withJSONObject: decoded)
  }
}
