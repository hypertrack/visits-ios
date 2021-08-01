import Utility


public struct MainState: Equatable {
  public var map: MapState
  public var orders: Set<Order>
  public var selectedOrder: Order?
  public var places: Set<Place>
  public var history: History?
  public var tab: TabSelection
  public var publishableKey: PublishableKey
  public var profile: Profile
  public var integrationStatus: IntegrationStatus
  public var requests: Set<Request>
  public var token: Token?
  
  public init(map: MapState, orders: Set<Order>, selectedOrder: Order? = nil, places: Set<Place>, history: History? = nil, tab: TabSelection, publishableKey: PublishableKey, profile: Profile, integrationStatus: IntegrationStatus = .unknown, requests: Set<Request> = [], token: Token? = nil) {
    self.map = map; self.orders = orders; self.selectedOrder = selectedOrder; self.places = places; self.history = history; self.tab = tab; self.publishableKey = publishableKey; self.profile = profile; self.integrationStatus = integrationStatus; self.requests = requests; self.token = token
  }
}
