public enum TabSelection: String, Equatable, Codable {
  case visits, map, summary, profile
  
  public static let defaultTab = Self.map
}
