public enum JSON {
  indirect case object(Object)
  indirect case array([JSON])
  case string(String)
  case number(Double)
  case bool(Bool)
  case null
  
  public typealias Object = [String: JSON]
}

extension JSON: Equatable {}
extension JSON: Hashable {}

extension JSON: Codable {
  public func encode(to encoder: Encoder) throws {
    switch self {
    case let .object(object):
      var container = encoder.container(keyedBy: DynamicKey.self)
      
      try object.forEach { (key: String, value: JSON) in
        try container.encode(value, forKey: DynamicKey(stringValue: key)!)
      }
    case let .array(array):
      var container = encoder.unkeyedContainer()
      
      for item in array {
        try container.encode(item)
      }
    case let .string(string):
      var container = encoder.singleValueContainer()
      
      try container.encode(string)
    case let .number(number):
      var container = encoder.singleValueContainer()
      
      try container.encode(number)
    case let .bool(bool):
      var container = encoder.singleValueContainer()
      
      try container.encode(bool)
    case .null:
      var container = encoder.singleValueContainer()
      
      try container.encode(Optional<Terminal?>.none)
    }
  }
  
  public init(from decoder: Decoder) throws {
    let singleValue = try decoder.singleValueContainer()
    
    if singleValue.decodeNil() {
      self = .null
      return
    }
    
    do {
      let number = try singleValue.decode(Double.self)
      self = .number(number)
      return
    } catch {}
    
    do {
      let string = try singleValue.decode(String.self)
      self = .string(string)
      return
    } catch {}
    
    do {
      let bool = try singleValue.decode(Bool.self)
      self = .bool(bool)
      return
    } catch {}
    
    do {
      var unkeyedContainer = try decoder.unkeyedContainer()
      var array: [JSON] = []
      while !unkeyedContainer.isAtEnd {
        array.append(try unkeyedContainer.decode(JSON.self))
      }
      self = .array(array)
      return
    } catch {}
    
    do {
      let keyedContainer = try decoder.container(keyedBy: DynamicKey.self)
      var object: [String: JSON] = [:]
      for key in keyedContainer.allKeys {
        object[key.stringValue] = try keyedContainer.decode(JSON.self, forKey: key)
      }
      self = .object(object)
      return
    } catch {}
    
    throw DecodingError.dataCorrupted(
      .init(codingPath: decoder.codingPath, debugDescription: "Unrecognized JSON")
    )
  }
}

extension JSON: ExpressibleByArrayLiteral {
  public init(arrayLiteral elements: JSON...) {
    self = .array(elements)
  }
}

extension JSON: ExpressibleByDictionaryLiteral {
  public init(dictionaryLiteral elements: (String, JSON)...) {
    self = .object(
      elements.reduce(into: [:]) { (result: inout [String: JSON], tuple: (key: String, json: JSON)) in
        result[tuple.key] = tuple.json
      }
    )
  }
}

extension JSON: ExpressibleByIntegerLiteral {
  public init(integerLiteral value: Int) {
    self = .number(Double(value))
  }
}

extension JSON: ExpressibleByFloatLiteral {
  public init(floatLiteral value: Double) {
    self = .number(value)
  }
}

extension JSON: ExpressibleByBooleanLiteral {
  public init(booleanLiteral value: Bool) {
    self = .bool(value)
  }
}

extension JSON: ExpressibleByNilLiteral {
  public init(nilLiteral: ()) {
    self = .null
  }
}

extension JSON: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    self = .string(value)
  }
}

extension JSON: ExpressibleByExtendedGraphemeClusterLiteral {
  public init(extendedGraphemeClusterLiteral value: String) {
    self = .string(value)
  }
}

extension JSON: ExpressibleByUnicodeScalarLiteral {
  public init(unicodeScalarLiteral value: String) {
    self = .string(value)
  }
}

extension JSON: ExpressibleByStringInterpolation {}
