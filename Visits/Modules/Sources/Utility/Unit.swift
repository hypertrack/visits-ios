public struct Unit {}

public let unit = Unit()

extension Unit: Equatable {}
extension Unit: Codable {}
extension Unit: Error {}

extension Unit: Comparable {
  public static func < (lhs: Unit, rhs: Unit) -> Bool { false }
}
