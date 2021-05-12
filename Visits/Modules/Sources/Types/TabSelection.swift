public enum TabSelection: Equatable {
  case map, orders, places, summary, profile
  
  public static let defaultTab = Self.map
}
