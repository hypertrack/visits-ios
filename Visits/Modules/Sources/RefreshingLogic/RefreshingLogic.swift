import AppArchitecture
import ComposableArchitecture
import Utility
import Types


// MARK: - State

public struct RefreshingState: Equatable {
  public var refreshing: Refreshing
  public var deviceID: DeviceID
  public var publishableKey: PublishableKey
  
  public init(refreshing: Refreshing, deviceID: DeviceID, publishableKey: PublishableKey) {
    self.refreshing = refreshing; self.deviceID = deviceID; self.publishableKey = publishableKey
  }
}

// MARK: - Action

public enum RefreshingAction: Equatable {
  case appVisibilityChanged(AppVisibility)
  case receivedPushNotification
  case mainUnlocked
  case startTracking
  case stopTracking
  case updateOrders
  case switchToOrders
  case ordersUpdated(Result<Set<Order>, APIError<Never>>)
  case orderCanceled
  case orderCompleted
  case updatePlaces
  case switchToPlaces
  case placesUpdated(Result<Set<Place>, APIError<Never>>)
  case switchToMap
  case historyUpdated(Result<History, APIError<Never>>)
}

// MARK: - Environment

public struct RefreshingEnvironment {
  public var getHistory: (PublishableKey, DeviceID, Date) -> Effect<Result<History, APIError<Never>>, Never>
  public var getOrders: (PublishableKey, DeviceID) -> Effect<Result<Set<Order>, APIError<Never>>, Never>
  public var getPlaces: (PublishableKey, DeviceID) -> Effect<Result<Set<Place>, APIError<Never>>, Never>
  public var reverseGeocode: (Coordinate) -> Effect<GeocodedResult, Never>
  
  public init(
    getHistory: @escaping (PublishableKey, DeviceID, Date) -> Effect<Result<History, APIError<Never>>, Never>,
    getOrders: @escaping (PublishableKey, DeviceID) -> Effect<Result<Set<Order>, APIError<Never>>, Never>,
    getPlaces: @escaping (PublishableKey, DeviceID) -> Effect<Result<Set<Place>, APIError<Never>>, Never>,
    reverseGeocode: @escaping (Coordinate) -> Effect<GeocodedResult, Never>
  ) {
    self.getHistory = getHistory
    self.getOrders = getOrders
    self.getPlaces = getPlaces
    self.reverseGeocode = reverseGeocode
  }
}

// MARK: - Reducer

public let refreshingReducer = Reducer<
  RefreshingState,
  RefreshingAction,
  SystemEnvironment<RefreshingEnvironment>
> { state, action, environment in
  
  let getOrders = getOrdersEffect(environment.getOrders(state.publishableKey, state.deviceID), environment.mainQueue)
  let getPlaces = getPlacesEffect(environment.getPlaces(state.publishableKey, state.deviceID), environment.reverseGeocode, environment.mainQueue)
  let getHistory = getHistoryEffect(environment.getHistory(state.publishableKey, state.deviceID, environment.date()), environment.mainQueue)
  
  switch action {
  case .appVisibilityChanged(.onScreen),
       .receivedPushNotification,
       .mainUnlocked,
       .startTracking:
    var effects: [Effect<RefreshingAction, Never>] = []
    if state.refreshing.history == .notRefreshingHistory {
      effects += [getHistory]
    }
    if state.refreshing.orders == .notRefreshingOrders {
      effects += [getOrders]
    }
    if state.refreshing.places == .notRefreshingPlaces {
      effects += [getPlaces]
    }
    
    state.refreshing = .all
    
    return .merge(effects)
  case .appVisibilityChanged(.offScreen),
      .stopTracking:
    var effects: [Effect<RefreshingAction, Never>] = []
    if state.refreshing.history == .refreshingHistory {
      effects += [.cancel(id: RefreshingHistoryID())]
    }
    if state.refreshing.orders == .refreshingOrders {
      effects += [.cancel(id: RefreshingOrdersID())]
    }
    if state.refreshing.places == .refreshingPlaces {
      effects += [.cancel(id: RefreshingPlacesID())]
    }
    
    state.refreshing = .none
    
    return .merge(effects)
  case .updateOrders, .switchToOrders, .orderCanceled, .orderCompleted:
    if state.refreshing.orders == .notRefreshingOrders {
      state.refreshing.orders = .refreshingOrders
      return getOrders
    } else {
      return .none
    }
  case .ordersUpdated:
    state.refreshing.orders = .notRefreshingOrders
    
    return .none
  case .updatePlaces, .switchToPlaces:
    if state.refreshing.places == .notRefreshingPlaces {
      state.refreshing.places = .refreshingPlaces
      return getPlaces
    } else {
      return .none
    }
  case .placesUpdated:
    state.refreshing.places = .notRefreshingPlaces
    
    return .none
  case .switchToMap:
    if state.refreshing.history == .notRefreshingHistory {
      state.refreshing.history = .refreshingHistory
      return getHistory
    } else {
      return .none
    }
  case .historyUpdated:
    state.refreshing.history = .notRefreshingHistory
    
    return .none
  }
}

struct RefreshingOrdersID: Hashable {}
struct RefreshingHistoryID: Hashable {}
struct RefreshingPlacesID: Hashable {}

let getOrdersEffect = { (
  getOrders: Effect<Result<Set<Order>, APIError>, Never>,
  mainQueue: AnySchedulerOf<DispatchQueue>
) in
  getOrders
    .receive(on: mainQueue)
    .eraseToEffect()
    .cancellable(id: RefreshingOrdersID())
    .map(RefreshingAction.ordersUpdated)
}

func getPlacesEffect(
  _ getPlaces: Effect<Result<Set<Place>, APIError<Never>>, Never>,
  _ reverseGeocode: @escaping (Coordinate) -> Effect<GeocodedResult, Never>,
  _ mainQueue: AnySchedulerOf<DispatchQueue>
) -> Effect<RefreshingAction, Never> {
  getPlaces
    .receive(on: mainQueue)
    .eraseToEffect()
    .cancellable(id: RefreshingPlacesID())
    .flatMap { (result: Result<Set<Place>, APIError<Never>>) -> Effect<RefreshingAction, Never> in
      switch result {
      case let .success(places):
        return reverseGeocodePlaces(
          places: Array(places),
          coordinateKeyPath: \Place.shape.centerCoordinate,
          addressLens: ^\Place.address,
          reverseGeocode: reverseGeocode
        )
        .map(Set.init)
        .map { RefreshingAction.placesUpdated(.success($0)) }
      case let .failure(error):
        return Effect(value: RefreshingAction.placesUpdated(.failure(error)))
      }
    }
    .eraseToEffect()
}

func reverseGeocodePlaces<P>(
  places: [P],
  coordinateKeyPath: KeyPath<P, Coordinate>,
  addressLens: Lens<P, Address>,
  reverseGeocode: @escaping (Coordinate) -> Effect<GeocodedResult, Never>
) -> Effect<[P], Never> {
  places.publisher
    .flatMap { place in
      reverseGeocode(place[keyPath: coordinateKeyPath])
        .map { (result: GeocodedResult) -> P in
          place |> addressLens *< result.address
        }
    }
    .collect()
    .eraseToEffect()
}

let getHistoryEffect = { (
  getHistory: Effect<Result<History, APIError>, Never>,
  mainQueue: AnySchedulerOf<DispatchQueue>
) in
  getHistory
  .receive(on: mainQueue)
  .eraseToEffect()
  .cancellable(id: RefreshingHistoryID())
  .map(RefreshingAction.historyUpdated)
}
