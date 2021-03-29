import Prelude

public struct Refreshing {
  public var history: History
  public var orders: Orders
  
  public enum History { case refreshingHistory, notRefreshingHistory }
  public enum Orders { case refreshingOrders, notRefreshingOrders }
  
  public init(history: History, orders: Orders) {
    self.history = history
    self.orders = orders
  }
}

// MARK: - Convenience

extension Refreshing {
  public static let none = Self(history: .notRefreshingHistory, orders: .notRefreshingOrders)
  public static let all = Self(history: .refreshingHistory, orders: .refreshingOrders)
}

// MARK: - Equatable

extension Refreshing: Equatable {}

extension Refreshing.History: Equatable {}
extension Refreshing.Orders: Equatable {}
