import AppArchitecture
import ComposableArchitecture
import IdentifiedCollections
import OrderLogic
import Utility
import Types


// MARK: - State

public struct OrdersState: Equatable {
  public var orders: IdentifiedArrayOf<Order>
  public var selectedId: Order.ID?
  
  public init(orders: IdentifiedArrayOf<Order>, selectedId: Order.ID? = nil) {
    self.orders = orders
    self.selectedId = selectedId
  }
  
  var selected: Order? {
    return orders[safeId: selectedId]
  }
  
}

// MARK: - Action

public enum OrdersAction: Equatable {
  case order(id: Order.ID, action: OrderAction)
  case selectOrder(Order.ID?)
  case ordersUpdated(Set<Order>)
}

// MARK: - Reducer

public let ordersReducer = Reducer<OrdersState, OrdersAction, SystemEnvironment<OrderEnvironment>>.combine(
  orderReducer.forEach(
    state: \.orders,
    action: /OrdersAction.order(id:action:),
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
    case .ordersUpdated(let updatedOrders):
      state.orders = IdentifiedArrayOf<Order>(uniqueElements: Array(updatedOrders).sortedOrders())
    case .selectOrder(let selectedOrder):
      state.selectedId = selectedOrder//?.id
    case .order(let id, let action):
      break
      //??
      
    }
    return .none
  }
)
