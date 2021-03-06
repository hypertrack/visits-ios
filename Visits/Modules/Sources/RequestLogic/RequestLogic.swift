import AppArchitecture
import ComposableArchitecture
import Utility
import Types


// MARK: - State

public struct RequestState: Equatable {
  public var requests: Set<Request>
  public var orders: Set<Order>
  public var deviceID: DeviceID
  public var publishableKey: PublishableKey
  public var token: Token?
  
  public init(requests: Set<Request>, orders: Set<Order>, deviceID: DeviceID, publishableKey: PublishableKey, token: Token? = nil) {
    self.requests = requests; self.orders = orders; self.deviceID = deviceID; self.publishableKey = publishableKey; self.token = token
  }
}

// MARK: - Action

public enum RequestAction: Equatable {
  case appVisibilityChanged(AppVisibility)
  case cancelOrder(Order)
  case completeOrder(Order)
  case historyUpdated(Result<History, APIError<Token.Expired>>)
  case mainUnlocked
  case orderCanceled(Order, Result<Terminal, APIError<Token.Expired>>)
  case orderCompleted(Order, Result<Terminal, APIError<Token.Expired>>)
  case ordersUpdated(Result<Set<Order>, APIError<Token.Expired>>)
  case placesUpdated(Result<Set<Place>, APIError<Token.Expired>>)
  case receivedPushNotification
  case startTracking
  case stopTracking
  case switchToMap
  case switchToOrders
  case switchToPlaces
  case tokenUpdated(Result<Token.Value, APIError<Never>>)
  case updateOrders
  case updatePlaces
}

// MARK: - Environment

public struct RequestEnvironment {
  public var cancelOrder: (Token.Value, PublishableKey, DeviceID, Order) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>
  public var completeOrder: (Token.Value, PublishableKey, DeviceID, Order) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>
  public var getHistory: (Token.Value, PublishableKey, DeviceID, Date) -> Effect<Result<History, APIError<Token.Expired>>, Never>
  public var getOrders: (Token.Value, PublishableKey, DeviceID) -> Effect<Result<Set<Order>, APIError<Token.Expired>>, Never>
  public var getPlaces: (Token.Value, PublishableKey, DeviceID) -> Effect<Result<Set<Place>, APIError<Token.Expired>>, Never>
  public var getToken: (PublishableKey, DeviceID) -> Effect<Result<Token.Value, APIError<Never>>, Never>
  public var reverseGeocode: (Coordinate) -> Effect<GeocodedResult, Never>
  public var updateOrderNote: (Token.Value, PublishableKey, DeviceID, Order, Order.Note) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>
  
  public init(
    cancelOrder: @escaping (Token.Value, PublishableKey, DeviceID, Order) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>,
    completeOrder: @escaping (Token.Value, PublishableKey, DeviceID, Order) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>,
    getHistory: @escaping (Token.Value, PublishableKey, DeviceID, Date) -> Effect<Result<History, APIError<Token.Expired>>, Never>,
    getOrders: @escaping (Token.Value, PublishableKey, DeviceID) -> Effect<Result<Set<Order>, APIError<Token.Expired>>, Never>,
    getPlaces: @escaping (Token.Value, PublishableKey, DeviceID) -> Effect<Result<Set<Place>, APIError<Token.Expired>>, Never>,
    getToken: @escaping (PublishableKey, DeviceID) -> Effect<Result<Token.Value, APIError<Never>>, Never>,
    reverseGeocode: @escaping (Coordinate) -> Effect<GeocodedResult, Never>,
    updateOrderNote: @escaping (Token.Value, PublishableKey, DeviceID, Order, Order.Note) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>
  ) {
    self.cancelOrder = cancelOrder
    self.completeOrder = completeOrder
    self.getHistory = getHistory
    self.getOrders = getOrders
    self.getPlaces = getPlaces
    self.getToken = getToken
    self.reverseGeocode = reverseGeocode
    self.updateOrderNote = updateOrderNote
  }
}

// MARK: - Reducer

public let requestReducer = Reducer<
  RequestState,
  RequestAction,
  SystemEnvironment<RequestEnvironment>
> { state, action, environment in
  
  let pk = state.publishableKey
  let deID = state.deviceID
  
  func cancelOrder(_ o: Order) -> (Token.Value) -> Effect<RequestAction, Never> {
    { t in cancelOrderEffect(o, environment.cancelOrder(t, pk, deID, o), { note in environment.updateOrderNote(t, pk, deID, o, note) }, environment.mainQueue) }
  }
  func completeOrder(_ o: Order) -> (Token.Value) -> Effect<RequestAction, Never> {
    { t in completeOrderEffect(o, environment.completeOrder(t, pk, deID, o), { note in environment.updateOrderNote(t, pk, deID, o, note) }, environment.mainQueue) }
  }
  func getOrders(_ t: Token.Value) -> Effect<RequestAction, Never> {
    getOrdersEffect(environment.getOrders(t, pk, deID), environment.mainQueue)
  }
  func getPlaces(_ t: Token.Value) -> Effect<RequestAction, Never> {
    getPlacesEffect(environment.getPlaces(t, pk, deID), environment.mainQueue)
  }
  func getHistory(_ t: Token.Value) -> Effect<RequestAction, Never> {
    getHistoryEffect(environment.getHistory(t, pk, deID, environment.date()), environment.mainQueue)
  }
  let getToken = getTokenEffect(environment.getToken(pk, deID), environment.mainQueue)
  
  func requestEffect(_ t: Token.Value) -> (Request) -> Effect<RequestAction, Never> {
    { r in
      switch r {
      case     .history:          return getHistory(t)
      case     .orders:           return getOrders(t)
      case     .places:           return getPlaces(t)
      }
    }
  }
  
  func cancelRequest(request r: Request) -> Effect<RequestAction, Never> {
    let id: AnyHashable
    switch r {
    case     .history:          id = RequestingHistoryID()
    case     .orders:           id = RequestingOrdersID()
    case     .places:           id = RequestingPlacesID()
    }
    return .cancel(id: id)
  }
  
  func requestOrRefreshToken(_ token: Token?, request: (Token.Value) -> Effect<RequestAction, Never>) -> (Token?, Effect<RequestAction, Never>) {
    switch token {
    case     .none:       return (.refreshing, getToken)
    case     .refreshing: return (token,       .none)
    case let .valid(t):   return (token,       request(t))
    }
  }
  
  switch action {
  case .appVisibilityChanged(.onScreen),
       .receivedPushNotification,
       .mainUnlocked,
       .startTracking:
    let (token, effects) = requestOrRefreshToken(state.token) { t in
      .merge(
        state.requests.symmetricDifference(Request.allCases)
          .map(requestEffect(t))
      )
    }
    
    state.token = token
    state.requests = Set(Request.allCases)
    
    return effects
  case .appVisibilityChanged(.offScreen):
    let effects = Effect<RequestAction, Never>.merge(
      state.requests.map(cancelRequest(request:))
    )
    
    state.requests = []
    
    return effects
  case .stopTracking:
    let effects = Effect<RequestAction, Never>.merge(
      state.requests.map(cancelRequest(request:))
      +
        [
          .cancel(id: RequestingCancelOrdersID()),
          .cancel(id: RequestingCompleteOrdersID()),
        ]
      +
      (state.token == .refreshing ? [.cancel(id: RequestingTokenID())] : [])
    )
    
    state.requests = []
    state.orders = state.orders.map { o in
        switch o.status {
        case .cancelling,
             .completing: return o |> \.status *< .ongoing(.unfocused)
        default:          return o
        }
      }
      |> Set.init
    state.token = state.token == .refreshing ? .none : state.token
    
    return effects
  case .switchToMap:
    guard !state.requests.contains(.history) else { return .none }
    
    let (token, effects) = requestOrRefreshToken(state.token, request: .history |> flip(requestEffect))
    
    state.token = token
    state.requests.insert(.history)
    
    return effects
  case .updateOrders, .switchToOrders:
    guard !state.requests.contains(.orders) else { return .none }
    
    let (token, effects) = requestOrRefreshToken(state.token, request: .orders |> flip(requestEffect))
    
    state.token = token
    state.requests.insert(.orders)
    
    return effects
  case .updatePlaces, .switchToPlaces:
    guard !state.requests.contains(.places) else { return .none }
    
    let (token, effects) = requestOrRefreshToken(state.token, request: .places |> flip(requestEffect))
    
    state.token = token
    state.requests.insert(.places)
    
    return effects
  case .ordersUpdated(.failure(.error)),
       .placesUpdated(.failure(.error)),
       .historyUpdated(.failure(.error)),
       .orderCompleted(_, .failure(.error)),
       .orderCanceled(_, .failure(.error)):
    state.token = .refreshing
    
    return getToken
  case let .orderCanceled(o, r):
    guard let order = state.orders.filter({ $0.id == o.id && $0.status == .cancelling }).first else { preconditionFailure() }
    
    state.orders.remove(order)
    state.orders.insert(order |> \.status *< (resultSuccess(r) != nil ? .cancelled : .ongoing(.unfocused)))
    
    if case .success = r, !state.requests.contains(.orders) {
      let (token, effects) = requestOrRefreshToken(state.token, request: .orders |> flip(requestEffect))
      state.token = token
      state.requests.insert(.orders)
      
      return effects
    }
    
    return .none
  case let .orderCompleted(o, r):
    guard let order = state.orders.filter({ $0.id == o.id && $0.status == .completing }).first else { preconditionFailure() }
    
    state.orders.remove(order)
    state.orders.insert(order |> \.status *< (resultSuccess(r) != nil ? .completed(environment.date()) : .ongoing(.unfocused)))
    
    if case .success = r, !state.requests.contains(.orders) {
      let (token, effects) = requestOrRefreshToken(state.token, request: .orders |> flip(requestEffect))
      state.token = token
      state.requests.insert(.orders)
      
      return effects
    }
    
    return .none
  case .ordersUpdated:
    guard state.requests.contains(.orders) else { preconditionFailure() }
    
    state.requests.remove(.orders)
    
    return .merge(
      .cancel(id: RequestingCancelOrdersID()),
      .cancel(id: RequestingCompleteOrdersID())
    )
  case .placesUpdated:
    guard state.requests.contains(.places) else { preconditionFailure() }
    
    state.requests.remove(.places)
    
    return .none
  case .historyUpdated:
    guard state.requests.contains(.history) else { preconditionFailure() }
    
    state.requests.remove(.history)
    
    return .none
  case let .cancelOrder(o):
    guard let order = state.orders.filter({
      guard $0.id == o.id, case .ongoing = $0.status else { return false }
      return true
    }).first else { preconditionFailure() }
    
    state.orders.remove(order)
    state.orders.insert(order |> \.status *< .cancelling)
    
    let (token, effects) = requestOrRefreshToken(state.token, request: cancelOrder(o))
    state.token = token
    
    return effects
  case let .completeOrder(o):
    guard let order = state.orders.filter({
      guard $0.id == o.id, case .ongoing = $0.status else { return false }
      return true
    }).first else { preconditionFailure() }
    
    state.orders.remove(order)
    state.orders.insert(order |> \.status *< .completing)
    
    let (token, effects) = requestOrRefreshToken(state.token, request: completeOrder(o))
    state.token = token
    
    return effects
  case let .tokenUpdated(.success(t)):
    guard state.token == .refreshing else { preconditionFailure() }
    
    state.token = .valid(t)
    
    return .merge(
      state.requests.map(requestEffect(t))
      +
      state.orders.compactMap { o in
        switch o.status {
        case .cancelling: return t |> cancelOrder(o)
        case .completing: return t |> completeOrder(o)
        default:          return nil
        }
      }
    )
  case .tokenUpdated(.failure):
    guard state.token == .refreshing else { preconditionFailure() }
    
    let effects = Effect<RequestAction, Never>.merge(
      state.requests.map(cancelRequest(request:))
      +
        [
          .cancel(id: RequestingCancelOrdersID()),
          .cancel(id: RequestingCompleteOrdersID()),
        ]
    )
    
    state.token = .none
    state.requests = []
    state.orders = state.orders.map { o in
        switch o.status {
        case .cancelling,
             .completing: return o |> \.status *< .ongoing(.unfocused)
        default:          return o
        }
      }
      |> Set.init
    
    return effects
  }
}

struct RequestingCancelOrdersID: Hashable {}
struct RequestingCompleteOrdersID: Hashable {}
struct RequestingOrdersID: Hashable {}
struct RequestingHistoryID: Hashable {}
struct RequestingPlacesID: Hashable {}
struct RequestingTokenID: Hashable {}

let cancelOrderEffect = { (
  order: Order,
  cancelOrder: Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>,
  updateOrderNote: (Order.Note) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>,
  mainQueue: AnySchedulerOf<DispatchQueue>
) ->  Effect<RequestAction, Never> in
  if let note = order.note {
    return updateOrderNote(note)
      .flatMap { (o: Order, r: Result<Terminal, APIError<Token.Expired>>) -> Effect<RequestAction, Never> in
        switch r {
        case     .success:    return cancelOrder.map(RequestAction.orderCanceled)
        case let .failure(e): return .init(value: .orderCanceled(o, .failure(e)))
        }
      }
      .receive(on: mainQueue)
      .eraseToEffect()
      .cancellable(id: RequestingCancelOrdersID(), cancelInFlight: false)
  } else {
    return cancelOrder
      .receive(on: mainQueue)
      .map(RequestAction.orderCanceled)
      .eraseToEffect()
      .cancellable(id: RequestingCancelOrdersID(), cancelInFlight: false)
  }
}

let completeOrderEffect = { (
  order: Order,
  completeOrder: Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>,
  updateOrderNote: (Order.Note) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>,
  mainQueue: AnySchedulerOf<DispatchQueue>
) ->  Effect<RequestAction, Never> in
  if let note = order.note {
    return updateOrderNote(note)
      .flatMap { (o: Order, r: Result<Terminal, APIError<Token.Expired>>) -> Effect<RequestAction, Never> in
        switch r {
        case     .success:    return completeOrder.map(RequestAction.orderCompleted)
        case let .failure(e): return .init(value: .orderCompleted(o, .failure(e)))
        }
      }
      .receive(on: mainQueue)
      .eraseToEffect()
      .cancellable(id: RequestingCompleteOrdersID(), cancelInFlight: false)
  } else {
    return completeOrder
      .receive(on: mainQueue)
      .map(RequestAction.orderCompleted)
      .eraseToEffect()
      .cancellable(id: RequestingCompleteOrdersID(), cancelInFlight: false)
  }
}

let getOrdersEffect = { (
  getOrders: Effect<Result<Set<Order>, APIError<Token.Expired>>, Never>,
  mainQueue: AnySchedulerOf<DispatchQueue>
) in
  getOrders
    .cancellable(id: RequestingOrdersID())
    .receive(on: mainQueue)
    .map(RequestAction.ordersUpdated)
    .eraseToEffect()
}

func getPlacesEffect(
  _ getPlaces: Effect<Result<Set<Place>, APIError<Token.Expired>>, Never>,
  _ mainQueue: AnySchedulerOf<DispatchQueue>
) -> Effect<RequestAction, Never> {
  getPlaces
    .cancellable(id: RequestingPlacesID())
    .receive(on: mainQueue)
    .map(RequestAction.placesUpdated)
    .eraseToEffect()
}

let getHistoryEffect = { (
  getHistory: Effect<Result<History, APIError<Token.Expired>>, Never>,
  mainQueue: AnySchedulerOf<DispatchQueue>
) in
  getHistory
    .cancellable(id: RequestingHistoryID())
    .receive(on: mainQueue)
    .map(RequestAction.historyUpdated)
    .eraseToEffect()
}

let getTokenEffect = { (
  getToken: Effect<Result<Token.Value, APIError<Never>>, Never>,
  mainQueue: AnySchedulerOf<DispatchQueue>
) in
  getToken
    .cancellable(id: RequestingTokenID())
    .receive(on: mainQueue)
    .map(RequestAction.tokenUpdated)
    .eraseToEffect()
}
