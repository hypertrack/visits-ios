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

// MARK: - Environment

public struct OrdersEnvironment {
  public var capture: (CaptureMessage) -> Effect<Never, Never>
  public var notifySuccess: () -> Effect<Never, Never>
  
  public init(capture: @escaping (CaptureMessage) -> Effect<Never, Never>, notifySuccess: @escaping () -> Effect<Never, Never>) {
    self.capture = capture; self.notifySuccess = notifySuccess
  }
}

// MARK: - Reducer

public let ordersReducer = Reducer<OrdersState, OrdersAction, SystemEnvironment<OrdersEnvironment>> { state, action, _ in
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

