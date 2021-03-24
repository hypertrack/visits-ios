import Prelude

public struct Refreshing {
  public var history: History
  public var visits: Visits
  
  public enum History { case refreshingHistory, notRefreshingHistory }
  public enum Visits { case refreshingVisits, notRefreshingVisits }
  
  public init(history: History, visits: Visits) {
    self.history = history
    self.visits = visits
  }
}

// MARK: - Convenience

extension Refreshing {
  public static let none = Self(history: .notRefreshingHistory, visits: .notRefreshingVisits)
  public static let all = Self(history: .refreshingHistory, visits: .refreshingVisits)
}

// MARK: - Equatable

extension Refreshing: Equatable {}

extension Refreshing.History: Equatable {}
extension Refreshing.Visits: Equatable {}
