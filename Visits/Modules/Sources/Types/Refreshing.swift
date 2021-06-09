import Utility

public struct Refreshing {
  public var history: History
  public var orders: Orders
  public var places: Places
  
  public enum History { case refreshingHistory, notRefreshingHistory }
  public enum Orders { case refreshingOrders, notRefreshingOrders }
  public enum Places { case refreshingPlaces, notRefreshingPlaces }
  
  public init(history: History, orders: Orders, places: Places) {
    self.history = history
    self.orders = orders
    self.places = places
  }
}

// MARK: - Convenience

extension Refreshing {
  public static let none = Self(history: .notRefreshingHistory, orders: .notRefreshingOrders, places: .notRefreshingPlaces)
  public static let all = Self(history: .refreshingHistory, orders: .refreshingOrders, places: .refreshingPlaces)
}

// MARK: - Equatable

extension Refreshing: Equatable {}

extension Refreshing.History: Equatable {}
extension Refreshing.Orders: Equatable {}
