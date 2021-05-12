public struct MainState: Equatable {
  public var orders: Set<Order>
  public var selectedOrder: Order?
  public var places: Set<Place>
  public var history: History?
  public var tab: TabSelection
  public var publishableKey: PublishableKey
  public var driverID: DriverID
  public var refreshing: Refreshing
  
  public init(orders: Set<Order>, selectedOrder: Order? = nil, places: Set<Place>, history: History? = nil, tab: TabSelection, publishableKey: PublishableKey, driverID: DriverID, refreshing: Refreshing) {
    self.orders = orders; self.selectedOrder = selectedOrder; self.places = places; self.history = history; self.tab = tab; self.publishableKey = publishableKey; self.driverID = driverID; self.refreshing = refreshing
  }
}
