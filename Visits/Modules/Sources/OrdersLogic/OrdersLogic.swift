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
  public var deviceID: DeviceID
  public var publishableKey: PublishableKey
  
  public init(orders: Set<Order>, selected: Order? = nil, deviceID: DeviceID, publishableKey: PublishableKey) {
    self.orders = orders; self.selected = selected; self.deviceID = deviceID; self.publishableKey = publishableKey
  }
  
  public var orderState: OrderState? {
    selected.map { .init(order: $0, deviceID: deviceID, publishableKey: publishableKey) }
  }
}

let orderSateAffine = Affine<OrdersState, OrderState>(
  extract: { s in
    s.selected.map {
      .init(
        order: $0,
        deviceID: s.deviceID,
        publishableKey: s.publishableKey
      )
    }
  },
  inject: { d in
    { s in
      s.selected.map { _ in
        s |> \.selected *< d.order
          <> \.deviceID *< d.deviceID
          <> \.publishableKey *< d.publishableKey
      }
    }
  }
)

// MARK: - Action

public enum OrdersAction: Equatable {
  case order(OrderAction)
  case selectOrder(String)
  case deselectOrder
  case ordersUpdated(Set<Order>)
}

// MARK: - Environment

public struct OrdersEnvironment {
  public var cancelOrder: (PublishableKey, DeviceID, Order) -> Effect<Result<Terminal, APIError<Never>>, Never>
  public var completeOrder: (PublishableKey, DeviceID, Order) -> Effect<Result<Terminal, APIError<Never>>, Never>
  public var notifySuccess: () -> Effect<Never, Never>
  public var openMap: (Coordinate, Either<FullAddress, Street>?) -> Effect<Never, Never>
  
  public init(
    cancelOrder: @escaping (PublishableKey, DeviceID, Order) -> Effect<Result<Terminal, APIError<Never>>, Never>,
    completeOrder: @escaping (PublishableKey, DeviceID, Order) -> Effect<Result<Terminal, APIError<Never>>, Never>,
    notifySuccess: @escaping () -> Effect<Never, Never>,
    openMap: @escaping (Coordinate, Either<FullAddress, Street>?) -> Effect<Never, Never>
  ) {
    self.cancelOrder = cancelOrder
    self.completeOrder = completeOrder
    self.notifySuccess = notifySuccess
    self.openMap = openMap
  }
}

// MARK: - Reducer

public let ordersReducer = Reducer<OrdersState, OrdersAction, SystemEnvironment<OrdersEnvironment>>.combine(
  orderReducer.pullback(
    state: orderSateAffine,
    action: /OrdersAction.order,
    environment: { e in
      e.map { e in
        .init(
          cancelOrder: e.cancelOrder,
          completeOrder: e.completeOrder,
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
    case let .selectOrder(str):
      
      
      
      let (os, o) = selectOrder(os: state.orders, o: state.selected, id: str)
      state.orders = os
      state.selected = o
      
      return .none
    case .deselectOrder:
      guard let o = state.selected else { return .none }
      
      state.orders = state.orders |> Set.insert(o)
      state.selected = nil
      
      return .none
    case let .ordersUpdated(os):
      if let id = state.selected?.id.string {
        let (newOs, newO) = selectOrder(os: state.orders, o: state.selected, id: id)
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

extension Set {
  static func insert(_ newMember: Element) -> (Self) -> Self {
    { set in
      var set = set
      set.insert(newMember)
      return set
    }
  }
}

func combine(_ os: Set<Order>, _ o: Order?) -> Set<Order> {
  o.map { Set.insert($0)(os) } ?? os
}

func selectOrder(os: Set<Order>, o: Order?, id: String) -> (Set<Order>, Order?) {
  let os = combine(os, o)
  let o: Order? = os.firstIndex(where: { $0.id.string == id }).map { os[$0] }
  return (os.filter { $0.id.string != id }, o)
}

func rewrap<Source, Value, Destination>(_ source: Tagged<Source, Value>) -> Tagged<Destination, Value> {
  .init(rawValue: source.rawValue)
}

func rewrapDictionary<A, B, C, D, E, F>(_ dict: Dictionary<Tagged<A, B>, Tagged<C, D>>) -> Dictionary<Tagged<E, B>, Tagged<F, D>> {
  Dictionary(uniqueKeysWithValues: dict.map { (rewrap($0), rewrap($1)) })
}
