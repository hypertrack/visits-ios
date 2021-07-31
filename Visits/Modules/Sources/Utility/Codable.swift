public struct DynamicKey: CodingKey {
  public var intValue: Int?
  public var stringValue: String
  
  public init?(intValue: Int) {
    self.intValue = intValue
    self.stringValue = "\(intValue)"
  }
  public init?(stringValue: String) {
    self.stringValue = stringValue
  }
}
