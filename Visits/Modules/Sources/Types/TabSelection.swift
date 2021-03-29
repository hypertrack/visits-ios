public enum TabSelection: String, Equatable, Codable {
  case map, orders, places, summary, profile
  
  public static let defaultTab = Self.map
}
