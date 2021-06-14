public struct Terminal {}

public let unit = Terminal()

extension Terminal: Equatable {}
extension Terminal: Codable {}
extension Terminal: Error {}

extension Terminal: Comparable {
  public static func < (lhs: Terminal, rhs: Terminal) -> Bool { false }
}
