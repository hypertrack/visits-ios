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
  case selectOrder(Order)
  case deselectOrder
  case ordersUpdated(Set<Order>)
}

// MARK: - Environment

public struct OrdersEnvironment {
  public var notifySuccess: () -> Effect<Never, Never>
  public var openMap: (Coordinate, Either<FullAddress, Street>?) -> Effect<Never, Never>
  
  public init(
    notifySuccess: @escaping () -> Effect<Never, Never>,
    openMap: @escaping (Coordinate, Either<FullAddress, Street>?) -> Effect<Never, Never>
  ) {
    self.notifySuccess = notifySuccess
    self.openMap = openMap
  }
}

// MARK: - Reducer

public let ordersReducer = Reducer<OrdersState, OrdersAction, SystemEnvironment<OrdersEnvironment>>.combine(
  orderReducer.optional().pullback(
    state: \.selected,
    action: /OrdersAction.order,
    environment: { e in
      e.map { e in
        .init(
          notifySuccess: e.notifySuccess,
          openMap: e.openMap
        )
      }
    }
  ),
  Reducer { state, action, environment in
    switch action {
    case .order:
      return .none
    case let .selectOrder(o):
      
      let (os, o) = selectOrder(os: state.orders, selected: state.selected, toSelect: o.id)
      state.orders = os
      state.selected = o
      
      return .none
    case .deselectOrder:
      guard let o = state.selected else { return .none }
      
      state.orders = state.orders |> Set.insert(o)
      state.selected = nil
      
      return .none
    case let .ordersUpdated(os):
      if let o = state.selected {
        let (newOs, newO) = selectOrder(os: os, selected: nil, toSelect: o.id)
        state.orders = newOs
        state.selected = newO
      } else {
        state.orders = os
        state.selected = nil
      }
      
      return .none
    }
  }
)

func combine(_ os: Set<Order>, _ o: Order?) -> Set<Order> {
  o.map { Set.insert($0)(os) } ?? os
}

func selectOrder(os: Set<Order>, selected: Order?, toSelect: Order.ID) -> (Set<Order>, Order?) {
  let os = combine(os, selected)
  let o: Order? = os.firstIndex(where: { $0.id.string == toSelect.string }).map { os[$0] }
  return (os.filter { $0.id.string != toSelect.string }, o)
}

func rewrap<Source, Value, Destination>(_ source: Tagged<Source, Value>) -> Tagged<Destination, Value> {
  .init(rawValue: source.rawValue)
}

func rewrapDictionary<A, B, C, D, E, F>(_ dict: Dictionary<Tagged<A, B>, Tagged<C, D>>) -> Dictionary<Tagged<E, B>, Tagged<F, D>> {
  Dictionary(uniqueKeysWithValues: dict.map { (rewrap($0), rewrap($1)) })
}
