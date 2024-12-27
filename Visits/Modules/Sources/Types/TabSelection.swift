public enum TabSelection: Equatable {
  case map, orders, places, profile, visits
  
  public static let defaultTab = Self.map
}
