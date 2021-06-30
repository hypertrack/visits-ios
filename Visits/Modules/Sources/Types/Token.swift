import NonEmpty
import Tagged


public enum Token: Equatable {
  case valid(Value)
  case refreshing
  
  public typealias Value = Tagged<(Token, value: ()), NonEmptyString>
  public struct Expired: Equatable {}
}

extension Token.Expired: Decodable {
  enum CodingKeys: String, CodingKey {
    case message
  }
  
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    let message = try values.decode(String.self, forKey: .message)
    
    if message != "Unauthorized" {
      throw DecodingError.dataCorrupted(
        DecodingError.Context(
          codingPath: decoder.codingPath,
          debugDescription: "Expected key message to have value Unauthorized"
        )
      )
    }
  }
}
