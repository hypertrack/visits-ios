import AppArchitecture
import ComposableArchitecture
import OrderLogic
import Utility
import Types


// MARK: - State

public struct OrdersState: Equatable {
  public var orders: Set<Order>
  public var selected: Order?
  
  public init(orders: Set<Order>, selected: Order? = nil) {
    self.orders = Set<Order>(orders)
    self.selected = selected
  }
}

// MARK: - Action

public enum OrdersAction: Equatable {
  case order(OrderAction)
  case selectOrder(Order?)
  case ordersUpdated(Set<Order>)
}

// MARK: - Reducer

public let ordersReducer = Reducer<OrdersState, OrdersAction, SystemEnvironment<OrderEnvironment>>.combine(
  orderReducer.optional().pullback(
    state: \.selected,
    action: /OrdersAction.order,
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
      state.orders = state.orders.updatedById(with: updatedOrders)
      state.selected = state.orders.first(where: { $0 == state.selected })
    case .selectOrder(let selectedOrder):
      state.selected = selectedOrder
    case .order:
      //update order in collection, after it was changed in OrderLogic
      if let selected = state.selected {
        state.orders = state.orders.updatedById(with: [selected])
      }
    }
    return .none
  }
)

