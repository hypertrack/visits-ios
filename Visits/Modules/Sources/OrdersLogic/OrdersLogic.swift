import AppArchitecture
import ComposableArchitecture
import NonEmpty
import OrderLogic
import Utility
import Tagged
import Types


// MARK: - State

public struct OrdersState: Equatable {
  public var orders: Set<Order>
  public var selected: Order?
  
  public init(orders: Set<Order>, selected: Order? = nil) { self.orders = orders; self.selected = selected }
}

// MARK: - Action

public enum OrdersAction: Equatable {
  case order(OrderAction)
  case selectOrder(Order?)
  case ordersUpdated(Set<Order>)
}

// MARK: - Reducer

public let ordersReducer = Reducer<OrdersState, OrdersAction, Void> { state, action, _ in
  switch action {
  case .ordersUpdated(let updatedOrders):
    state.orders = state.orders.updatedById(with: updatedOrders)
    state.selected = state.orders.first(where: { $0 == state.selected })
  case .selectOrder(let selectedOrder):
    state.selected = selectedOrder
  case .order:
    break
  }
  return .none
}

