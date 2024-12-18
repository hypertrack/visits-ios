public enum TabSelection: Equatable {
  case map, visits, places, orders, profile, team
  
  public static let defaultTab = Self.map
}
