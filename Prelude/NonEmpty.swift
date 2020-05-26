import Foundation

public struct NonEmptyString: Equatable {
  let firstCharacter: Character
  let restOfTheString: String
  
  
  public init?(rawValue: String) {
    if let firstCharacter = rawValue.first {
      self.firstCharacter = firstCharacter
      self.restOfTheString = String(rawValue.dropFirst())
    } else {
      return nil
    }
  }
  
  public var rawValue: String {
    String(firstCharacter) + restOfTheString
  }
}

extension NonEmptyString: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    self.init(rawValue: value)!
  }
}

extension NonEmptyString: Hashable {}
extension NonEmptyString: Decodable {
  public init(from decoder: Decoder) throws {
    let string = try String(from: decoder)
    
    guard !string.isEmpty else {
      throw DecodingError.dataCorrupted(
        .init(codingPath: decoder.codingPath, debugDescription: "Non-empty string expected")
      )
    }
    self.init(rawValue: string)!
  }
}

public struct NonEmptyArray<T> {
  let firstElement: T
  let restoOfArray: [T]
  
  public init?(rawValue: [T]) {
    if let firstElement = rawValue.first {
      self.firstElement = firstElement
      self.restoOfArray = Array(rawValue.dropFirst())
    } else {
      return nil
    }
  }
  
  public init(_ arrayLiteral: [T]) {
    self.init(rawValue: arrayLiteral)!
  }
  
  public init(_ elements: T...) {
    self.init(rawValue: elements)!
  }
  
  public var rawValue: [T] {
    [firstElement] + restoOfArray
  }
}

