import AppArchitecture
import ComposableArchitecture
import IdentifiedCollections
import OrderLogic
import Utility
import Types
import NonEmpty


// MARK: - State

public struct TripState: Equatable {

//  public var id: NonEmptyString
//  public var createdAt: Date
//  public var status: Trip.Status
//
//  public var orders: IdentifiedArrayOf<Order>
  public var trip: Trip?
  public var selectedOrderId: Order.ID?
  
  public init(//id: NonEmptyString, createdAt: Date, status: Trip.Status, orders: IdentifiedArrayOf<Order>, selectedOrderId: Order.ID? = nil) {
    trip: Trip?, selectedOrderId: Order.ID? = nil) {
//    self.orders = orders
    self.trip = trip
    self.selectedOrderId = selectedOrderId
//    self.id = id
//    self.createdAt = createdAt
//    self.status = status
  }
  
//  var selectedOrder: Order? {
//    return trip?.orders[safeId: selectedOrderId]
//  }
}

// MARK: - Action

public enum TripAction: Equatable {
  case order(id: Order.ID, action: OrderAction)
  case selectOrder(Order.ID?)
  case tripUpdated(Trip?)
}

// MARK: - Reducer

public let tripReducer = Reducer<TripState, TripAction, SystemEnvironment<OrderEnvironment>>.combine(
  orderReducer.forEach(
    state: \.trip!.orders,
    action: /TripAction.order(id:action:),
    environment: { e in
      e.map { e in
        .init(
          capture: e.capture,
          notifySuccess: e.notifySuccess
        )
      }
    }
  ),
  Reducer { state, action, _ in    
    switch action {
    case .tripUpdated(let trip):
      state.trip = trip
    case .selectOrder(let selectedOrderId):
      state.selectedOrderId = selectedOrderId
    case .order(let id, let action):
      break
    }
    return .none
  }
)
