import AppArchitecture
import ComposableArchitecture
import Utility
import Types
import IdentifiedCollections


// MARK: - State

public struct RequestState: Equatable {
  public var requests: Set<Request>
  public var trip: Trip?
  public var history: History?
  public var integrationStatus: IntegrationStatus
  public var deviceID: DeviceID
  public var publishableKey: PublishableKey
  public var token: Token?
  
  public init(requests: Set<Request>, trip: Trip?, history: History? = nil, integrationStatus: IntegrationStatus, deviceID: DeviceID, publishableKey: PublishableKey, token: Token? = nil) {
    self.requests = requests
    self.trip = trip
    self.integrationStatus = integrationStatus
    self.deviceID = deviceID
    self.publishableKey = publishableKey
    self.token = token
  }
}

// MARK: - Action

public enum RequestAction: Equatable {
  case appVisibilityChanged(AppVisibility)
  case cancelAllRequests
  case cancelOrder(Order)
  case completeOrder(Order)
  case historyUpdated(Result<History, APIError<Token.Expired>>)
  case createPlace(PlaceCenter, PlaceRadius, IntegrationEntity, CustomAddress?, PlaceDescription?)
  case placeCreatedWithSuccess(Place)
  case placeCreatedWithFailure(APIError<Token.Expired>)
  case updateIntegrations(IntegrationSearch)
  case integrationEntitiesUpdatedWithSuccess([IntegrationEntity])
  case integrationEntitiesUpdatedWithFailure(APIError<Token.Expired>)
  case mainUnlocked
  case orderCanceled(Order, Result<Terminal, APIError<Token.Expired>>)
  case orderCompleted(Order, Result<Terminal, APIError<Token.Expired>>)
  case tripUpdated(Result<Trip?, APIError<Token.Expired>>)
  case profileUpdated(Result<Profile, APIError<Token.Expired>>)
  case placesUpdated(Result<PlacesSummary, APIError<Token.Expired>>)
  case receivedCurrentLocation(Coordinate?)
  case receivedPushNotification
  case refreshAllRequests
  case startTracking
  case stopTracking
  case switchToMap
  case switchToOrders
  case switchToPlaces
  case switchToProfile
  case tokenUpdated(Result<Token.Value, APIError<Never>>)
  case updateOrders
  case updatePlaces
}

// MARK: - Environment

public struct RequestEnvironment {
  public var cancelOrder: (Token.Value, DeviceID, Order) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>
  public var capture: (CaptureMessage) -> Effect<Never, Never>
  public var completeOrder: (Token.Value, DeviceID, Order) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>
  public var createPlace: (Token.Value, DeviceID, PlaceCenter, PlaceRadius, IntegrationEntity, CustomAddress?, PlaceDescription?) -> Effect<Result<Place, APIError<Token.Expired>>, Never>
  public var getCurrentLocation: () -> Effect<Coordinate?, Never>
  public var getHistory: (Token.Value, DeviceID, Date) -> Effect<Result<History, APIError<Token.Expired>>, Never>
  public var getIntegrationEntities: (Token.Value, IntegrationLimit, IntegrationSearch) -> Effect<Result<[IntegrationEntity], APIError<Token.Expired>>, Never>
  public var getTrip: (Token.Value, DeviceID) -> Effect<Result<Trip?, APIError<Token.Expired>>, Never>
//  public var getOrders: (Token.Value, DeviceID) -> Effect<Result<Set<Order>, APIError<Token.Expired>>, Never>
  public var getPlaces:  (Token.Value, DeviceID, PublishableKey, Date, Calendar) -> Effect<Result<PlacesSummary, APIError<Token.Expired>>, Never>
  public var getProfile: (Token.Value, DeviceID) -> Effect<Result<Profile, APIError<Token.Expired>>, Never>
  public var getToken: (PublishableKey, DeviceID) -> Effect<Result<Token.Value, APIError<Never>>, Never>
  public var reverseGeocode: (Coordinate) -> Effect<GeocodedResult, Never>
  public var updateOrderNote: (Token.Value, DeviceID, Order, Order.Note) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>
  
  public init(
    cancelOrder: @escaping (Token.Value, DeviceID, Order) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>,
    capture: @escaping (CaptureMessage) -> Effect<Never, Never>,
    completeOrder: @escaping (Token.Value, DeviceID, Order) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>,
    createPlace: @escaping (Token.Value, DeviceID, PlaceCenter, PlaceRadius, IntegrationEntity, CustomAddress?, PlaceDescription?) -> Effect<Result<Place, APIError<Token.Expired>>, Never>,
    getCurrentLocation: @escaping () -> Effect<Coordinate?, Never>,
    getHistory: @escaping (Token.Value, DeviceID, Date) -> Effect<Result<History, APIError<Token.Expired>>, Never>,
    getIntegrationEntities: @escaping (Token.Value, IntegrationLimit, IntegrationSearch) -> Effect<Result<[IntegrationEntity], APIError<Token.Expired>>, Never>,
    getTrip: @escaping (Token.Value, DeviceID) -> Effect<Result<Trip?, APIError<Token.Expired>>, Never>,
//    getOrders: @escaping (Token.Value, DeviceID) -> Effect<Result<Set<Order>, APIError<Token.Expired>>, Never>,
    getPlaces: @escaping  (Token.Value, DeviceID, PublishableKey, Date, Calendar) -> Effect<Result<PlacesSummary, APIError<Token.Expired>>, Never>,
    getProfile: @escaping (Token.Value, DeviceID) -> Effect<Result<Profile, APIError<Token.Expired>>, Never>,
    getToken: @escaping (PublishableKey, DeviceID) -> Effect<Result<Token.Value, APIError<Never>>, Never>,
    reverseGeocode: @escaping (Coordinate) -> Effect<GeocodedResult, Never>,
    updateOrderNote: @escaping (Token.Value, DeviceID, Order, Order.Note) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>
  ) {
    self.cancelOrder = cancelOrder
    self.capture = capture
    self.completeOrder = completeOrder
    self.createPlace = createPlace
    self.getCurrentLocation = getCurrentLocation
    self.getHistory = getHistory
    self.getIntegrationEntities = getIntegrationEntities
    self.getTrip = getTrip
//    self.getOrders = getOrders
    self.getPlaces = getPlaces
    self.getProfile = getProfile
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
    { t in cancelOrderEffect(o, environment.cancelOrder(t, deID, o), { note in environment.updateOrderNote(t, deID, o, note) }, environment.mainQueue) }
  }
  func completeOrder(_ o: Order) -> (Token.Value) -> Effect<RequestAction, Never> {
    { t in completeOrderEffect(o, environment.completeOrder(t, deID, o), { note in environment.updateOrderNote(t, deID, o, note) }, environment.mainQueue) }
  }
  func getTrip(_ t: Token.Value) -> Effect<RequestAction, Never> {
    getTripEffect(environment.getTrip(t, deID), environment.mainQueue)
  }
//  func getOrders(_ t: Token.Value) -> Effect<RequestAction, Never> {
//    getOrdersEffect(environment.getOrders(t, deID), environment.mainQueue)
//  }
  
  func getPlaces(_ t: Token.Value) -> Effect<RequestAction, Never> {
    getPlacesEffect(environment.getPlaces(t, deID, pk, environment.date(), environment.calendar()), environment.mainQueue)
  }
  func getProfile(_ t: Token.Value) -> Effect<RequestAction, Never> {
    getProfileEffect(environment.getProfile(t, deID), environment.mainQueue)
  }
  func getHistory(_ t: Token.Value) -> Effect<RequestAction, Never> {
    getHistoryEffect(environment.getHistory(t, deID, environment.date()), environment.mainQueue)
  }
  func getIntegrationEntities(_ t: Token.Value, _ s: IntegrationSearch) -> Effect<RequestAction, Never> {
    getIntegrationEntitiesEffect(environment.getIntegrationEntities(t, 50, s), environment.mainQueue)
  }
  
  let getToken = getTokenEffect(environment.getToken(pk, deID), environment.mainQueue)
  
  func requestEffect(_ t: Token.Value) -> (Request) -> Effect<RequestAction, Never> {
    { r in
      switch r {
      case .history:  return getHistory(t)
      case .trip:    return getTrip(t)
//      case .orders:   return getOrders(t)
      case .places:   return getPlaces(t)
      case .profile:  return getProfile(t)
      }
    }
  }
  
  func cancelRequest(request r: Request) -> Effect<RequestAction, Never> {
    let id: AnyHashable
    switch r {
    case .history:  id = RequestingHistoryID()
    case .trip:     id = RequestingTripsID()
//    case .orders:   id = RequestingOrdersID()
    case .places:   id = RequestingPlacesID()
    case .profile:  id = RequestingProfileID()
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
       .startTracking,
       .refreshAllRequests:
    let isIntegrationCheckPending = state.integrationStatus == .unknown
    
    let (token, effects) = requestOrRefreshToken(state.token) { t in
      .merge(
        state.requests.symmetricDifference(Request.allCases)
          .map(requestEffect(t))
          + [(isIntegrationCheckPending ? getIntegrationEntities(t, "") : .none)]
      )
    }
    
    state.token = token
    state.requests = Set(Request.allCases)
    state.integrationStatus = isIntegrationCheckPending ? .requesting : state.integrationStatus

    if state.history.noLocations {
      return .merge(
        effects,
        environment.getCurrentLocation()
          .map(RequestAction.receivedCurrentLocation)
      )
    }

    return effects
  case let .receivedCurrentLocation(.some(c)):

    switch state.history {
    case .none:
      state.history = .init(coordinates: [c])
    case let .some(h) where h.coordinates.isEmpty:
      state.history = h |> \.coordinates *< [c]
    default:
      break
    }

    return .none
  case .receivedCurrentLocation(.none):
    return .none
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
    let ordersArray: [Order] = state.trip?.orders.map { o in
        switch o.status {
        case .cancelling,
             .completing: return o |> \.status *< .ongoing(.unfocused)
        default:          return o
        }
      } ?? []
    state.trip?.orders = IdentifiedArrayOf<Order>(uniqueElements: ordersArray)
    state.token = state.token == .refreshing ? .none : state.token
    
    return effects
  case .switchToMap:
    guard !state.requests.contains(.history) else { return .none }
    
    let (token, effects) = requestOrRefreshToken(state.token, request: .history |> flip(requestEffect))
    
    state.token = token
    state.requests.insert(.history)
    
    return effects
  case .updateOrders:
    guard !state.requests.contains(.trip) else { return .none }
    
    let (token, effects) = requestOrRefreshToken(state.token, request: .trip |> flip(requestEffect))
    
    state.token = token
    state.requests.insert(.trip)
    
    return effects
  case .updatePlaces, .placeCreatedWithSuccess:
    guard !state.requests.contains(.places) else { return .none }
    
    let (token, effects) = requestOrRefreshToken(state.token, request: .places |> flip(requestEffect))
    
    state.token = token
    state.requests.insert(.places)
    
    return effects
  case .switchToProfile:
    guard !state.requests.contains(.profile) else { return .none }
    
    let (token, effects) = requestOrRefreshToken(state.token, request: .profile |> flip(requestEffect))
    
    state.token = token
    state.requests.insert(.profile)
    
    return effects
  case .tripUpdated(.failure(.error)),
       .placesUpdated(.failure(.error)),
       .historyUpdated(.failure(.error)),
       .placeCreatedWithFailure(.error),
       .integrationEntitiesUpdatedWithFailure(.error),
       .profileUpdated(.failure(.error)),
       .orderCompleted(_, .failure(.error)),
       .orderCanceled(_, .failure(.error)):
    state.token = .refreshing
    
    return getToken
  case let .orderCanceled(o, r):
    guard let order = state.trip?.orders.filter({ $0.id == o.id && $0.status == .cancelling }).first
    else { return environment.capture("Can't process order cancellation because there is no order or its status is not .cancelling").fireAndForget() }
    
    state.trip?.orders.updateOrAppend(order |> \.status *< (resultSuccess(r) != nil ? .cancelled : .ongoing(.unfocused)))
    
    if case .success = r, !state.requests.contains(.trip) {
      let (token, effects) = requestOrRefreshToken(state.token, request: .trip |> flip(requestEffect))
      state.token = token
      state.requests.insert(.trip)
      
      return effects
    }
    
    return .none
  case let .orderCompleted(o, r):
    guard let order = state.trip?.orders.filter({ $0.id == o.id && $0.status == .completing }).first
    else { return environment.capture("Can't process order completion because there is no order or its status is not .completing").fireAndForget() }
    
    state.trip?.orders.remove(order)
    state.trip?.orders.updateOrAppend(order |> \.status *< (resultSuccess(r) != nil ? .completed(environment.date()) : .ongoing(.unfocused)))
    
    if case .success = r, !state.requests.contains(.trip) {
      let (token, effects) = requestOrRefreshToken(state.token, request: .trip |> flip(requestEffect))
      state.token = token
      state.requests.insert(.trip)
      
      return effects
    }
    
    return .none
  case .tripUpdated:
    guard state.requests.contains(.trip) else { return .none }
    
    state.requests.remove(.trip)
    
    return .merge(
      .cancel(id: RequestingCancelOrdersID()),
      .cancel(id: RequestingCompleteOrdersID())
    )
  case .placesUpdated:
    guard state.requests.contains(.places) else { return .none }
    
    state.requests.remove(.places)
    
    return .none
  case .historyUpdated:
    guard state.requests.contains(.history) else { return .none }
    
    state.requests.remove(.history)
    
    return .none
  case .profileUpdated:
    guard state.requests.contains(.profile) else { return .none }
    
    state.requests.remove(.profile)
    
    return .none
  case let .updateIntegrations(s):
    guard case .integrated = state.integrationStatus
    else { return environment.capture("Trying to search for integrations without an integrated status").fireAndForget() }
    
    let (token, effects) = requestOrRefreshToken(state.token) { t in getIntegrationEntities(t, s) }
    
    state.token = token
    state.integrationStatus = .integrated(.refreshing(s))
    
    return effects
  case .integrationEntitiesUpdatedWithFailure,
       .integrationEntitiesUpdatedWithSuccess:
    
    if case .integrated(.refreshing) = state.integrationStatus {
      state.integrationStatus = .integrated(.notRefreshing)
    }
    
    return .none
  case let .cancelOrder(o):
    guard let order = state.trip?.orders.filter({
      guard $0.id == o.id, case .ongoing = $0.status else { return false }
      return true
    }).first
    else { return .none }
    
    state.trip?.orders.updateOrAppend(order |> \.status *< .cancelling)
    
    let (token, effects) = requestOrRefreshToken(state.token, request: cancelOrder(o))
    state.token = token
    
    return effects
  case let .completeOrder(o):
    guard let order = state.trip?.orders.filter({
      guard $0.id == o.id, case .ongoing = $0.status else { return false }
      return true
    }).first
    else { return .none }
    
    state.trip?.orders.updateOrAppend(order |> \.status *< .completing)
    
    let (token, effects) = requestOrRefreshToken(state.token, request: completeOrder(o))
    state.token = token
    
    return effects
  case let .tokenUpdated(.success(t)):
    guard state.token == .refreshing else { return .none }
    
    state.token = .valid(t)
    
    let requestIntegration: Effect<RequestAction, Never>
    switch state.integrationStatus {
    case     .requesting:                 requestIntegration = getIntegrationEntities(t, "")
    case let .integrated(.refreshing(s)): requestIntegration = getIntegrationEntities(t, s)
    default:                              requestIntegration = .none
    }
    let orders = state.trip?.orders ?? IdentifiedArrayOf<Order>()
    return .merge(
      state.requests.map(requestEffect(t))
      +
      orders.compactMap { o in
        switch o.status {
        case .cancelling: return t |> cancelOrder(o)
        case .completing: return t |> completeOrder(o)
        default:          return nil
        }
      }
      +
      [requestIntegration]
    )
  case .tokenUpdated(.failure):
    guard state.token == .refreshing else { return .none }
    
    let cancelIntegrationRequest: Effect<RequestAction, Never>
    switch state.integrationStatus {
    case     .requesting, .integrated(.refreshing): cancelIntegrationRequest = .cancel(id: RequestingIntegrationEntitiesID())
    default:                                        cancelIntegrationRequest = .none
    }
    
    let effects = Effect<RequestAction, Never>.merge(
      state.requests.map(cancelRequest(request:))
      +
        [
          .cancel(id: RequestingCancelOrdersID()),
          .cancel(id: RequestingCompleteOrdersID()),
        ]
      +
        []
    )
    
    state.token = .none
    state.requests = []
    
    let ordersArray: [Order] = state.trip?.orders.map { o in
        switch o.status {
        case .cancelling,
             .completing: return o |> \.status *< .ongoing(.unfocused)
        default:          return o
        }
      } ?? []
    state.trip?.orders = IdentifiedArrayOf(uniqueElements: ordersArray)
    switch state.integrationStatus {
    case .requesting:              state.integrationStatus = .unknown
    case .integrated(.refreshing): state.integrationStatus = .integrated(.notRefreshing)
    default:                       break
    }
    
    return effects
  case let .createPlace(c, r, ie, a, d):
    guard case let .some(token) = state.token
    else { return environment.capture("Trying to create a place without a token").fireAndForget() }
    
    if case let .valid(token) = token {
      return createPlaceEffect(
        environment.createPlace(token, state.deviceID, c, r, ie, a, d),
        environment.mainQueue
      )
    }
    
    return .none
  case .placeCreatedWithFailure:
    return .none
  case .cancelAllRequests:
    
    state.token = .none
    state.requests = []
    let ordersArray: [Order] = state.trip?.orders.map { o in
        switch o.status {
        case .cancelling,
             .completing: return o |> \.status *< .ongoing(.unfocused)
        default:          return o
        }
      } ?? []
    state.trip?.orders = IdentifiedArrayOf(uniqueElements: ordersArray)
    state.integrationStatus = .unknown
    
    return .merge(
      .cancel(id: RequestingCancelOrdersID()),
      .cancel(id: RequestingCompleteOrdersID()),
      .cancel(id: RequestingOrdersID()),
      .cancel(id: RequestingTripsID()),
      .cancel(id: RequestingHistoryID()),
      .cancel(id: RequestingIntegrationEntitiesID()),
      .cancel(id: RequestingPlacesID()),
      .cancel(id: RequestingCreatePlaceID()),
      .cancel(id: RequestingProfileID()),
      .cancel(id: RequestingTokenID())
    )
  case .switchToPlaces, .switchToOrders:
    return .none
  }
}

extension Optional where Wrapped == History {
  var noLocations: Bool {
    switch self {
    case     .none:                                return true
    case let .some(h) where h.coordinates.isEmpty: return true
    default:                                       return false
    }
  }
}

struct RequestingCancelOrdersID: Hashable {}
struct RequestingCompleteOrdersID: Hashable {}
struct RequestingOrdersID: Hashable {}
struct RequestingTripsID: Hashable {}
struct RequestingHistoryID: Hashable {}
struct RequestingIntegrationEntitiesID: Hashable {}
struct RequestingPlacesID: Hashable {}
struct RequestingCreatePlaceID: Hashable {}
struct RequestingProfileID: Hashable {}
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

let getTripEffect = { (getTrip: Effect<Result<Trip?, APIError<Token.Expired>>, Never>,
                        queue: AnySchedulerOf<DispatchQueue>) in
  getTrip
    .cancellable(id: RequestingTripsID())
    .receive(on: queue)
    .map(RequestAction.tripUpdated)
    .eraseToEffect()
}

//let getOrdersEffect = { (
//  getOrders: Effect<Result<Set<Order>, APIError<Token.Expired>>, Never>,
//  mainQueue: AnySchedulerOf<DispatchQueue>
//) in
//  getOrders
//    .cancellable(id: RequestingOrdersID())
//    .receive(on: mainQueue)
//    .map(RequestAction.ordersUpdated)
//    .eraseToEffect()
//}

func getPlacesEffect(
  _ getPlaces: Effect<Result<PlacesSummary, APIError<Token.Expired>>, Never>,
  _ mainQueue: AnySchedulerOf<DispatchQueue>
) -> Effect<RequestAction, Never> {
  getPlaces
    .cancellable(id: RequestingPlacesID())
    .receive(on: mainQueue)
    .map(RequestAction.placesUpdated)
    .eraseToEffect()
}

func createPlaceEffect(
  _ createPlace: Effect<Result<Place, APIError<Token.Expired>>, Never>,
  _ mainQueue: AnySchedulerOf<DispatchQueue>
) -> Effect<RequestAction, Never> {
  createPlace
    .cancellable(id: RequestingCreatePlaceID(), cancelInFlight: true)
    .receive(on: mainQueue)
    .map { r in
      switch r {
      case let .success(p): return .placeCreatedWithSuccess(p)
      case let .failure(e): return .placeCreatedWithFailure(e)
      }
    }
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

let getIntegrationEntitiesEffect = { (
  getIntegrationEntities: Effect<Result<[IntegrationEntity], APIError<Token.Expired>>, Never>,
  mainQueue: AnySchedulerOf<DispatchQueue>
) in
  getIntegrationEntities
    .cancellable(id: RequestingIntegrationEntitiesID(), cancelInFlight: true)
    .receive(on: mainQueue)
    .map { r -> RequestAction in
      switch r {
      case let .success(ies): return .integrationEntitiesUpdatedWithSuccess(ies)
      case let .failure(e):   return .integrationEntitiesUpdatedWithFailure(e)
      }
    }
    .eraseToEffect()
}

let getProfileEffect = { (
  getProfile: Effect<Result<Profile, APIError<Token.Expired>>, Never>,
  mainQueue: AnySchedulerOf<DispatchQueue>
) in
  getProfile
    .cancellable(id: RequestingProfileID())
    .receive(on: mainQueue)
    .map(RequestAction.profileUpdated)
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
