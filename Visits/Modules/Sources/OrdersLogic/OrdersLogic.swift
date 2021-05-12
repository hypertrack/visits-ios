import AppArchitecture
import ComposableArchitecture
import NonEmpty
import OrderLogic
import Prelude
import Tagged
import Types


// MARK: - State

public struct OrdersState: Equatable {
  public var orders: Set<Order>
  public var selected: Order?
  
  public init(orders: Set<Order>, selected: Order? = nil) {
    self.orders = orders; self.selected = selected
  }
}

// MARK: - Action

public enum OrdersAction: Equatable {
  case order(OrderAction)
  case selectOrder(String)
  case deselectOrder
  case ordersUpdated(NonEmptyDictionary<APIOrderID, APIOrder>)
  case reverseGeocoded([GeocodedResult])
}

// MARK: - Environment

public struct OrdersEnvironment {
  public var addGeotag: (Geotag) -> Effect<Never, Never>
  public var notifySuccess: () -> Effect<Never, Never>
  public var openMap: (Coordinate, Either<FullAddress, Street>?) -> Effect<Never, Never>
  public var reverseGeocode: (Coordinate) -> Effect<GeocodedResult, Never>
  
  public init(
    addGeotag: @escaping (Geotag) -> Effect<Never, Never>,
    notifySuccess: @escaping () -> Effect<Never, Never>,
    openMap: @escaping (Coordinate, Either<FullAddress, Street>?) -> Effect<Never, Never>,
    reverseGeocode: @escaping (Coordinate) -> Effect<GeocodedResult, Never>
  ) {
    self.addGeotag = addGeotag
    self.notifySuccess = notifySuccess
    self.openMap = openMap
    self.reverseGeocode = reverseGeocode
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
          addGeotag: e.addGeotag,
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
      
      return .none
    case let .ordersUpdated(os):
      let allOs = combine(state.orders, state.selected)
      var updatedOs = os.rawValue |> updateFromAPI(allOs)
      let freshOs = updatedOs |> Set.removeOld(now: environment.date())
      
      let (newOs, newO): (Set<Order>, Order?)
      if let id = state.selected?.id.string {
        (newOs, newO) = selectOrder(os: freshOs, o: nil, id: id)
      } else {
        (newOs, newO) = (freshOs, nil)
      }
      
      state.orders = newOs
      state.selected = newO
      
      if let reverseGeocodingCoordinates = NonEmptySet(rawValue: orderCoordinatesWithoutAddress(freshOs)) {
        return reverseGeocodingCoordinates.publisher
          .flatMap(environment.reverseGeocode)
          .collect()
          .receive(on: environment.mainQueue)
          .eraseToEffect()
          .map(OrdersAction.reverseGeocoded)
      } else {
        return .none
      }
    case let .reverseGeocoded(g):
      
      state.orders = updateAddress(for: state.orders, with: g)
      state.selected = state.selected <¡> updateAddress(with: g)
      
      return .none
    }
  }
)

func orderCoordinatesWithoutAddress(_ orders: Set<Order>) -> Set<Coordinate> {
  Set(orders.compactMap { $0.address == .none ? $0.location : nil })
}

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

func updateFromAPI(_ os: Set<Order>) -> ([APIOrderID: APIOrder]) -> Set<Order> {
  { apiOs in
    Set(
      apiOs.map { tuple in
        if let match = os.first(where: { tuple.key.rawValue == $0.id.rawValue }) {
          return update(order: match, with: (tuple.key, tuple.value))
        } else {
          return Order(apiOrder: (tuple.key, tuple.value))
        }
      }
      +
      os.compactMap { o in
        if apiOs[rewrap(o.id)] == nil {
          return o
        } else {
          return nil
        }
      }
    )
  }
}

func update(order: Order?, with apiOrder: (id: APIOrderID, order: APIOrder) ) -> Order {
  guard var order = order else { return .init(apiOrder: apiOrder) }

  order.geotagSent.isVisited = apiOrder.order.visitStatus.map(Order.Geotag.Visited.init(visitStatus:))
  
  return order
}

extension Order {
  init(apiOrder: (id: APIOrderID, order: APIOrder)) {
    let source: Order.Source
    switch apiOrder.order.source {
    case .order: source = .order
    case .trip: source = .trip
    }
    
    self.init(
      id: rewrap(apiOrder.id),
      createdAt: apiOrder.order.createdAt,
      source: source,
      location: apiOrder.order.centroid,
      geotagSent: .notSent,
      noteFieldFocused: false,
      address: .none,
      orderNote: nil,
      metadata: rewrapDictionary(apiOrder.order.metadata)
    )
  }
}

extension Order.Geotag.Visited {
  init(visitStatus: VisitStatus) {
    switch visitStatus {
    case let .entered(entry): self = .entered(entry)
    case let .visited(entry, exit): self = .visited(entry, exit)
    }
  }
}

func rewrap<Source, Value, Destination>(_ source: Tagged<Source, Value>) -> Tagged<Destination, Value> {
  .init(rawValue: source.rawValue)
}

func rewrapDictionary<A, B, C, D, E, F>(_ dict: Dictionary<Tagged<A, B>, Tagged<C, D>>) -> Dictionary<Tagged<E, B>, Tagged<F, D>> {
  Dictionary(uniqueKeysWithValues: dict.map { (rewrap($0), rewrap($1)) })
}

func updateAddress(for orders: Set<Order>, with geocodedResults: [GeocodedResult]) -> Set<Order> {
  Set(orders.map(updateAddress(with: geocodedResults)))
}

func updateAddress(with geocodedResults: [GeocodedResult]) -> (Order) -> Order {
  {
    var v = $0
    for g in geocodedResults where v.location == g.coordinate {
      v.address = g.address
    }
    return v
  }
}

