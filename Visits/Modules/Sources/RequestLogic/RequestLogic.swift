import AppArchitecture
import ComposableArchitecture
import Utility
import Types
import APIEnvironmentLive


// MARK: - State

public struct RequestState: Equatable {
  public var requests: Set<Request>
  public var deviceID: DeviceID
  public var publishableKey: PublishableKey
  public var token: Token?
  
  public init(requests: Set<Request>, deviceID: DeviceID, publishableKey: PublishableKey, token: Token? = nil) {
    self.requests = requests; self.deviceID = deviceID; self.publishableKey = publishableKey; self.token = token
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
  
  public init(
    cancelOrder: @escaping (Token.Value, PublishableKey, DeviceID, Order) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>,
    completeOrder: @escaping (Token.Value, PublishableKey, DeviceID, Order) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>,
    getHistory: @escaping (Token.Value, PublishableKey, DeviceID, Date) -> Effect<Result<History, APIError<Token.Expired>>, Never>,
    getOrders: @escaping (Token.Value, PublishableKey, DeviceID) -> Effect<Result<Set<Order>, APIError<Token.Expired>>, Never>,
    getPlaces: @escaping (Token.Value, PublishableKey, DeviceID) -> Effect<Result<Set<Place>, APIError<Token.Expired>>, Never>,
    getToken: @escaping (PublishableKey, DeviceID) -> Effect<Result<Token.Value, APIError<Never>>, Never>,
    reverseGeocode: @escaping (Coordinate) -> Effect<GeocodedResult, Never>
  ) {
    self.cancelOrder = cancelOrder
    self.completeOrder = completeOrder
    self.getHistory = getHistory
    self.getOrders = getOrders
    self.getPlaces = getPlaces
    self.getToken = getToken
    self.reverseGeocode = reverseGeocode
  }
}

// MARK: - Reducer

public let requestReducer = Reducer<
  RequestState,
  RequestAction,
  SystemEnvironment<RequestEnvironment>
> { state, action, environment in
  
  func cancelOrder(_ t: Token.Value, _ o: Order) -> Effect<RequestAction, Never> {
    cancelOrderEffect(o.id, environment.cancelOrder(t, state.publishableKey, state.deviceID, o), environment.mainQueue)
  }
  func completeOrder(_ t: Token.Value, _ o: Order) -> Effect<RequestAction, Never> {
    completeOrderEffect(o.id, environment.completeOrder(t, state.publishableKey, state.deviceID, o), environment.mainQueue)
  }
  func getOrders(_ t: Token.Value) -> Effect<RequestAction, Never> {
    getOrdersEffect(environment.getOrders(t, state.publishableKey, state.deviceID), environment.mainQueue)
  }
  func getPlaces(_ t: Token.Value) -> Effect<RequestAction, Never> {
    getPlacesEffect(environment.getPlaces(t, state.publishableKey, state.deviceID), environment.mainQueue)
  }
  func getHistory(_ t: Token.Value) -> Effect<RequestAction, Never> {
    getHistoryEffect(environment.getHistory(t, state.publishableKey, state.deviceID, environment.date()), environment.mainQueue)
  }
  let getToken = getTokenEffect(environment.getToken(state.publishableKey, state.deviceID), environment.mainQueue)
  
  func requestEffect(request r: Request, token t: Token.Value) -> Effect<RequestAction, Never> {
    switch r {
    case let .cancelOrder(o):   return cancelOrder(t, o)
    case let .completeOrder(o): return completeOrder(t, o)
    case     .history:          return getHistory(t)
    case     .orders:           return getOrders(t)
    case     .places:           return getPlaces(t)
    }
  }
  
  func cancelRequest(request r: Request) -> Effect<RequestAction, Never> {
    let id: AnyHashable
    switch r {
    case let .cancelOrder(o):   id = RequestingCancelOrderID(orderID: o.id)
    case let .completeOrder(o): id = RequestingCompleteOrderID(orderID: o.id)
    case     .history:          id = RequestingHistoryID()
    case     .orders:           id = RequestingOrdersID()
    case     .places:           id = RequestingPlacesID()
    }
    return .cancel(id: id)
  }
  
  func requestByRefreshingToken(_ r: Request) -> Effect<RequestAction, Never> {
    var effect: Effect<RequestAction, Never>
    switch state.token {
    case     .none:
      state.token = .refreshing
      
      effect = getToken
    case let .valid(t):
      if !state.requests.contains(r) {
        effect = requestEffect(request: r, token: t)
      } else {
        effect = .none
      }
    case     .refreshing:
      effect = .none
    }
    
    state.requests.insert(r)
    
    return effect
  }
  
  switch action {
  case .appVisibilityChanged(.onScreen),
       .receivedPushNotification,
       .mainUnlocked,
       .startTracking:
    
    return .merge(
      requestByRefreshingToken(.history),
      requestByRefreshingToken(.orders),
      requestByRefreshingToken(.places)
    )
  case .appVisibilityChanged(.offScreen),
       .stopTracking:
    
    var effects: [Effect<RequestAction, Never>] = []
    var requestsToCancel = Set<Request>()
    
    func cancelAndRemove(_ r: Request) {
      requestsToCancel.insert(r)
      effects.append(cancelRequest(request: r))
    }
    
    for r in state.requests {
      switch r {
      case .cancelOrder, .completeOrder:
        if case .stopTracking = action {
          cancelAndRemove(r)
        }
      case .history, .orders, .places:
        cancelAndRemove(r)
      }
    }
    state.requests = state.requests.subtracting(requestsToCancel)
    
    if case .stopTracking = action, state.token == .refreshing {
      state.token = .none
      effects.append(.cancel(id: RequestingTokenID()))
    }
    
    return .merge(effects)
  case .switchToMap:
    return requestByRefreshingToken(.history)
  case .updateOrders, .switchToOrders:
    return requestByRefreshingToken(.orders)
  case .updatePlaces, .switchToPlaces:
    return requestByRefreshingToken(.places)
  case .ordersUpdated(.failure(.error)),
       .placesUpdated(.failure(.error)),
       .historyUpdated(.failure(.error)),
       .orderCompleted(_, .failure(.error)),
       .orderCanceled(_, .failure(.error)):
    state.token = .refreshing
    
    return getToken
  case let .orderCanceled(o, .success):
    guard state.requests.contains(.cancelOrder(o)) else { preconditionFailure() }
    
    state.requests.remove(.cancelOrder(o))
    
    return requestByRefreshingToken(.orders)
  case let .orderCanceled(o, .failure):
    guard state.requests.contains(.cancelOrder(o)) else { preconditionFailure() }
    
    state.requests.remove(.cancelOrder(o))
    
    return .none
  case let .orderCompleted(o, .failure):
    guard state.requests.contains(.completeOrder(o)) else { preconditionFailure() }
    
    state.requests.remove(.completeOrder(o))
    
    return .none
  case let .orderCompleted(o, .success):
    guard state.requests.contains(.completeOrder(o)) else { preconditionFailure() }
    
    state.requests.remove(.completeOrder(o))
    
    return requestByRefreshingToken(.orders)
  case .ordersUpdated:
    guard state.requests.contains(.orders) else { preconditionFailure() }
    
    state.requests.remove(.orders)
    
    return .none
  case .placesUpdated:
    guard state.requests.contains(.places) else { preconditionFailure() }
    
    state.requests.remove(.places)
    
    return .none
  case .historyUpdated:
    guard state.requests.contains(.history) else { preconditionFailure() }
    
    state.requests.remove(.history)
    
    return .none
  case let .cancelOrder(o):
    guard case let request = Request.cancelOrder(o), !state.requests.contains(request) else { preconditionFailure() }
    
    return requestByRefreshingToken(request)
  case let .completeOrder(o):
    guard case let request = Request.completeOrder(o), !state.requests.contains(request) else { preconditionFailure() }
    
    return requestByRefreshingToken(request)
  case let .tokenUpdated(.success(t)):
    state.token = .valid(t)
    
    return .merge(state.requests.map { requestEffect(request: $0, token: t) })
  case .tokenUpdated(.failure):
    state.token = .none
    
    let r = state.requests
    state.requests = []
    
    return .merge(r.map(cancelRequest(request:)))
  }
}

struct RequestingCancelOrderID: Hashable { let orderID: Order.ID }
struct RequestingCompleteOrderID: Hashable { let orderID: Order.ID }
struct RequestingOrdersID: Hashable {}
struct RequestingHistoryID: Hashable {}
struct RequestingPlacesID: Hashable {}
struct RequestingTokenID: Hashable {}

let cancelOrderEffect = { (
  orderID: Order.ID,
  cancelOrder: Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>,
  mainQueue: AnySchedulerOf<DispatchQueue>
) in
  cancelOrder
    .cancellable(id: RequestingCancelOrderID(orderID: orderID))
    .receive(on: mainQueue)
    .map(RequestAction.orderCanceled)
    .eraseToEffect()
}

let completeOrderEffect = { (
  orderID: Order.ID,
  completeOrder: Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>,
  mainQueue: AnySchedulerOf<DispatchQueue>
) in
  completeOrder
    .cancellable(id: RequestingCompleteOrderID(orderID: orderID))
    .receive(on: mainQueue)
    .map(RequestAction.orderCompleted)
    .eraseToEffect()
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
