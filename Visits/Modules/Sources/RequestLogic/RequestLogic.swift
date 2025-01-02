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
  public var workerHandle: WorkerHandle

  public init(
    requests: Set<Request>,
    trip: Trip?,
    history: History? = nil,
    integrationStatus: IntegrationStatus,
    deviceID: DeviceID,
    publishableKey: PublishableKey,
    token: Token? = nil,
    workerHandle: WorkerHandle
  ) {
    self.requests = requests
    self.trip = trip
    self.integrationStatus = integrationStatus
    self.deviceID = deviceID
    self.publishableKey = publishableKey
    self.token = token
    self.workerHandle = workerHandle
  }
}

// MARK: - Action

public enum RequestAction: Equatable {
  case appVisibilityChanged(AppVisibility)
  case cancelAllRequests
  case requestOrderCancel(Order)
  case requestOrderComplete(Order)
  case requestOrderSnooze(Order)
  case requestOrderUnsnooze(Order)
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
  case orderSnoozed(Order, Result<Terminal, APIError<Token.Expired>>)
  case orderUnsnoozed(Order, Result<Terminal, APIError<Token.Expired>>)
  case tripUpdated(Result<Trip?, APIError<Token.Expired>>)
  case profileUpdated(Result<Profile, APIError<Token.Expired>>)
  case placesUpdated(Result<PlacesSummary, APIError<Token.Expired>>)
  case receivedCurrentLocation(Coordinate?)
  case receivedPushNotification
  case refreshAllRequests
  case resetInProgressOrders
  case startTracking
  case stopTracking
  case switchToMap
  case switchToOrders
  case switchToPlaces
  case switchToProfile
  case switchToVisits
  case teamUpdated(Result<TeamValue?, APIError<Token.Expired>>)
  case tokenUpdated(Result<Token.Value, APIError<Never>>)
  case updateOrders
  case updatePlaces
  case updateVisits(from: Date, to: Date, WorkerHandle)
  case updateTeam
  case visitsUpdated(Result<VisitsData, APIError<Token.Expired>>)
}

// MARK: - Environment

public struct RequestEnvironment {
  public var cancelOrder: (Token.Value, DeviceID, Order, Trip.ID) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>
  public var capture: (CaptureMessage) -> Effect<Never, Never>
  public var completeOrder: (Token.Value, DeviceID, Order, Trip.ID) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>
  public var snoozeOrder: (Token.Value, DeviceID, Order, Trip.ID) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>
  public var unsnoozeOrder: (Token.Value, DeviceID, Order, Trip.ID) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>
  public var createPlace: (Token.Value, DeviceID, PlaceCenter, PlaceRadius, IntegrationEntity, CustomAddress?, PlaceDescription?) -> Effect<Result<Place, APIError<Token.Expired>>, Never>
  public var getCurrentLocation: () -> Effect<Coordinate?, Never>
  public var getHistory: (Token.Value, DeviceID, Date) -> Effect<Result<History, APIError<Token.Expired>>, Never>
  public var getIntegrationEntities: (Token.Value, IntegrationLimit, IntegrationSearch) -> Effect<Result<[IntegrationEntity], APIError<Token.Expired>>, Never>
  public var getTrip: (Token.Value, DeviceID) -> Effect<Result<Trip?, APIError<Token.Expired>>, Never>
  public var getPlaces:  (Token.Value, DeviceID, PublishableKey, Date, Calendar) -> Effect<Result<PlacesSummary, APIError<Token.Expired>>, Never>
  public var getProfile: (Token.Value, DeviceID) -> Effect<Result<Profile, APIError<Token.Expired>>, Never>
  public var getTeam: (Token.Value, WorkerHandle) -> Effect<Result<TeamValue?, APIError<Token.Expired>>, Never>
  public var getToken: (PublishableKey, DeviceID) -> Effect<Result<Token.Value, APIError<Never>>, Never>
  public var getVisits: (Token.Value, WorkerHandle, Date, Date) -> Effect<Result<VisitsData, APIError<Token.Expired>>, Never>
    
  public var reverseGeocode: (Coordinate) -> Effect<GeocodedResult, Never>
  public var updateOrderNote: (Token.Value, DeviceID, Order, Trip.ID, Order.Note) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>
  
  public init(
    cancelOrder: @escaping (Token.Value, DeviceID, Order, Trip.ID) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>,
    capture: @escaping (CaptureMessage) -> Effect<Never, Never>,
    completeOrder: @escaping (Token.Value, DeviceID, Order, Trip.ID) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>,
    snoozeOrder: @escaping (Token.Value, DeviceID, Order, Trip.ID) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>,
    unsnoozeOrder: @escaping (Token.Value, DeviceID, Order, Trip.ID) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>,
    createPlace: @escaping (Token.Value, DeviceID, PlaceCenter, PlaceRadius, IntegrationEntity, CustomAddress?, PlaceDescription?) -> Effect<Result<Place, APIError<Token.Expired>>, Never>,
    getCurrentLocation: @escaping () -> Effect<Coordinate?, Never>,
    getHistory: @escaping (Token.Value, DeviceID, Date) -> Effect<Result<History, APIError<Token.Expired>>, Never>,
    getIntegrationEntities: @escaping (Token.Value, IntegrationLimit, IntegrationSearch) -> Effect<Result<[IntegrationEntity], APIError<Token.Expired>>, Never>,
    getTrip: @escaping (Token.Value, DeviceID) -> Effect<Result<Trip?, APIError<Token.Expired>>, Never>,
    getPlaces: @escaping  (Token.Value, DeviceID, PublishableKey, Date, Calendar) -> Effect<Result<PlacesSummary, APIError<Token.Expired>>, Never>,
    getProfile: @escaping (Token.Value, DeviceID) -> Effect<Result<Profile, APIError<Token.Expired>>, Never>,
    getTeam: @escaping (Token.Value, WorkerHandle) -> Effect<Result<TeamValue?, APIError<Token.Expired>>, Never>,
    getToken: @escaping (PublishableKey, DeviceID) -> Effect<Result<Token.Value, APIError<Never>>, Never>,
    getVisits: @escaping (Token.Value, WorkerHandle, Date, Date) -> Effect<Result<VisitsData, APIError<Token.Expired>>, Never>,
    reverseGeocode: @escaping (Coordinate) -> Effect<GeocodedResult, Never>,
    updateOrderNote: @escaping (Token.Value, DeviceID, Order, Trip.ID, Order.Note) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>
  ) {
    self.cancelOrder = cancelOrder
    self.capture = capture
    self.completeOrder = completeOrder
    self.snoozeOrder = snoozeOrder
    self.unsnoozeOrder = unsnoozeOrder
    self.createPlace = createPlace
    self.getCurrentLocation = getCurrentLocation
    self.getHistory = getHistory
    self.getIntegrationEntities = getIntegrationEntities
    self.getTrip = getTrip
    self.getPlaces = getPlaces
    self.getProfile = getProfile
    self.getTeam = getTeam
    self.getToken = getToken
    self.getVisits = getVisits
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
  
  func cancelOrder(_ o: Order, _ tripID: Trip.ID) -> (Token.Value) -> Effect<RequestAction, Never> {
    { t in cancelOrderEffect(o, environment.cancelOrder(t, deID, o, tripID), { note in environment.updateOrderNote(t, deID, o, tripID, note) }, environment.mainQueue) }
  }
  func completeOrder(_ o: Order, _ tripID: Trip.ID) -> (Token.Value) -> Effect<RequestAction, Never> {
    { t in completeOrderEffect(o, environment.completeOrder(t, deID, o, tripID), { note in environment.updateOrderNote(t, deID, o, tripID, note) }, environment.mainQueue) }
  }
  func snoozeOrder(_ o: Order, _ tripID: Trip.ID) -> (Token.Value) -> Effect<RequestAction, Never> {
    { t in snoozeOrderEffect(o, environment.snoozeOrder(t, deID, o, tripID), { note in environment.updateOrderNote(t, deID, o, tripID, note) }, environment.mainQueue) }
  }
  func unsnoozeOrder(_ o: Order, _ tripID: Trip.ID) -> (Token.Value) -> Effect<RequestAction, Never> {
    { t in unsnoozeOrderEffect(o, environment.unsnoozeOrder(t, deID, o, tripID), { note in environment.updateOrderNote(t, deID, o, tripID, note) }, environment.mainQueue) }
  }
  func getTrip(_ t: Token.Value) -> Effect<RequestAction, Never> {
    getTripEffect(environment.getTrip(t, deID), environment.mainQueue)
  }
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
  func getTeam(_ t: Token.Value, _ wh: WorkerHandle) -> Effect<RequestAction, Never> {
    getTeamEffect(environment.getTeam(t, wh), environment.mainQueue)
  }
  func getVisits(_ t: Token.Value, _ wh: WorkerHandle, from: Date, to: Date) -> Effect<RequestAction, Never> {
    getVisitsEffect(environment.getVisits(t, wh, from, to), environment.mainQueue)
  }

  
  let getToken = getTokenEffect(environment.getToken(pk, deID), environment.mainQueue)
  
  func requestEffect(_ t: Token.Value) -> (Request) -> Effect<RequestAction, Never> {
    { r in
      switch r {
      case .deviceHistory:  return getHistory(t)
      case .oldestActiveTrip:    return getTrip(t)
      case .placesAndVisits:   return getPlaces(t)
      case .deviceMetadata:  return getProfile(t)
      }
    }
  }
  
  func cancelRequest(request r: Request) -> Effect<RequestAction, Never> {
    let id: AnyHashable
    switch r {
    case .deviceHistory:            id = RequestingHistoryID()
    case .oldestActiveTrip:         id = RequestingTripsID()
    case .placesAndVisits:          id = RequestingPlacesID()
    case .deviceMetadata:           id = RequestingProfileID()
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
    
    // Initial loading of the app data is performed here
    let (token, effects) = requestOrRefreshToken(state.token) { t in
      .merge(
        // get all requests that are not already in progress
        state.requests.symmetricDifference(Request.allCases)
          .map(requestEffect(t))
          + [(isIntegrationCheckPending ? getIntegrationEntities(t, "") : .none)]
          + [ getVisits(t, state.workerHandle, from: environment.date(), to: environment.date()) ]
          + [ getTeam(t, state.workerHandle) ]
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
          .cancel(id: RequestingSnoozeOrdersID()),
          .cancel(id: RequestingUnsnoozeOrdersID())
        ]
      +
      (state.token == .refreshing ? [.cancel(id: RequestingTokenID())] : [])
      +
        [.init(value: .resetInProgressOrders)]
    )
    
    state.requests = []
    state.token = state.token == .refreshing ? .none : state.token
    
    return effects
  case .switchToMap:
    guard !state.requests.contains(.deviceHistory) else { return .none }
    
    let (token, effects) = requestOrRefreshToken(state.token, request: .deviceHistory |> flip(requestEffect))
    
    state.token = token
    state.requests.insert(.deviceHistory)
    
    return effects
  case let .updateIntegrations(s):
    guard case .integrated = state.integrationStatus
    else { return environment.capture("Trying to search for integrations without an integrated status").fireAndForget() }

    let (token, effects) = requestOrRefreshToken(state.token) { t in getIntegrationEntities(t, s) }

    state.token = token
    state.integrationStatus = .integrated(.refreshing(s))

    return effects
  case .updateOrders:
    guard !state.requests.contains(.oldestActiveTrip) else { return .none }
    
    let (token, effects) = requestOrRefreshToken(state.token, request: .oldestActiveTrip |> flip(requestEffect))
    
    state.token = token
    state.requests.insert(.oldestActiveTrip)
    
    return effects
  case .updatePlaces, .placeCreatedWithSuccess, .switchToPlaces:
    guard !state.requests.contains(.placesAndVisits) else { return .none }
    
    let (token, effects) = requestOrRefreshToken(state.token, request: .placesAndVisits |> flip(requestEffect))
    
    state.token = token
    state.requests.insert(.placesAndVisits)
    
    return effects
  case let .updateVisits(from: from, to: to, wh):
    let (token, effects) = requestOrRefreshToken(state.token) { t in getVisits(t, wh, from: from, to: to) }
    
    state.token = token

    return effects
  case .updateTeam:
      let (token, effects) = requestOrRefreshToken(state.token) { t in getTeam(t, WorkerHandle.init("ram@hypertrack.io")) }

    state.token = token

    return effects
  case .switchToProfile:
    guard !state.requests.contains(.deviceMetadata) else { return .none }
    
    let (token, effects) = requestOrRefreshToken(state.token, request: .deviceMetadata |> flip(requestEffect))
    
    state.token = token
    state.requests.insert(.deviceMetadata)
    
    return effects
  case .tripUpdated(.failure(.error)),
       .placesUpdated(.failure(.error)),
       .historyUpdated(.failure(.error)),
       .placeCreatedWithFailure(.error),
       .integrationEntitiesUpdatedWithFailure(.error),
       .profileUpdated(.failure(.error)),
       .orderCompleted(_, .failure(.error)),
       .orderCanceled(_, .failure(.error)),
       .orderSnoozed(_, .failure(.error)),
       .orderUnsnoozed(_, .failure(.error)),
       .teamUpdated(.failure(.error)),
       .visitsUpdated(.failure(.error)):
    state.token = .refreshing
    
    return getToken
  case .orderCanceled(_, .success),
       .orderCompleted(_, .success),
       .orderSnoozed(_, .success),
       .orderUnsnoozed(_, .success):
    guard !state.requests.contains(.oldestActiveTrip) else { return .none }

    let (token, effects) = requestOrRefreshToken(state.token, request: .oldestActiveTrip |> flip(requestEffect))
    state.token = token
    state.requests.insert(.oldestActiveTrip)

    return effects
  case .orderCanceled,
       .orderCompleted,
       .orderSnoozed,
       .orderUnsnoozed:
    return .none
  case .tripUpdated:
    guard state.requests.contains(.oldestActiveTrip) else { return .none }
    
    state.requests.remove(.oldestActiveTrip)
    
    return .merge(
      .cancel(id: RequestingCancelOrdersID()),
      .cancel(id: RequestingCompleteOrdersID()),
      .cancel(id: RequestingSnoozeOrdersID()),
      .cancel(id: RequestingUnsnoozeOrdersID())
    )
  case .placesUpdated:
    guard state.requests.contains(.placesAndVisits) else { return .none }
    
    state.requests.remove(.placesAndVisits)
    
    return .none
  case .visitsUpdated:
    return .none
  case .teamUpdated:
    return .none
  case .historyUpdated:
    guard state.requests.contains(.deviceHistory) else { return .none }
    
    state.requests.remove(.deviceHistory)
    
    return .none
  case .profileUpdated:
    guard state.requests.contains(.deviceMetadata) else { return .none }
    
    state.requests.remove(.deviceMetadata)
    
    return .none
  case .integrationEntitiesUpdatedWithFailure,
       .integrationEntitiesUpdatedWithSuccess:
    
    if case .integrated(.refreshing) = state.integrationStatus {
      state.integrationStatus = .integrated(.notRefreshing)
    }
    
    return .none
  case let .requestOrderCancel(o):
    guard let trip = state.trip else { return .none }
    
    let (token, effects) = requestOrRefreshToken(state.token, request: cancelOrder(o, trip.id))
    state.token = token
    
    return effects
  case let .requestOrderComplete(o):
    guard let trip = state.trip else { return .none }
    
    let (token, effects) = requestOrRefreshToken(state.token, request: completeOrder(o, trip.id))
    state.token = token
    
    return effects
  case let .requestOrderSnooze(o):
    guard let trip = state.trip else { return .none }

    let (token, effects) = requestOrRefreshToken(state.token, request: snoozeOrder(o, trip.id))
    state.token = token

    return effects

  case let .requestOrderUnsnooze(o):
    guard let trip = state.trip else { return .none }

    let (token, effects) = requestOrRefreshToken(state.token, request: unsnoozeOrder(o, trip.id))
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

    let resumeOrderCancellationAndCompletion: [Effect<RequestAction, Never>]
    if let trip = state.trip, !trip.orders.isEmpty {
      resumeOrderCancellationAndCompletion = trip.orders.compactMap { o in
        switch o.status {
        case .cancelling: return t |> cancelOrder(o, trip.id)
        case .completing: return t |> completeOrder(o, trip.id)
        case .snoozing:   return t |> snoozeOrder(o, trip.id)
        case .unsnoozing: return t |> unsnoozeOrder(o, trip.id)
        default:          return nil
        }
      }
    } else {
      resumeOrderCancellationAndCompletion = []
    }

    // Initial app data loading after the token is updated
    return .merge(
      state.requests.map(requestEffect(t))
      +
      resumeOrderCancellationAndCompletion
      +
      [requestIntegration]
      +
      [ getVisits(t, state.workerHandle, from: environment.date(), to: environment.date()) ]
      +
      [ getTeam(t, state.workerHandle) ]
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
          .cancel(id: RequestingSnoozeOrdersID()),
          .cancel(id: RequestingUnsnoozeOrdersID())
        ]
      +
        [cancelIntegrationRequest]
      +
        [.init(value: .resetInProgressOrders)]
    )
    
    state.token = .none
    state.requests = []

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
    state.integrationStatus = .unknown
    
    return .merge(
      .cancel(id: RequestingCancelOrdersID()),
      .cancel(id: RequestingCompleteOrdersID()),
      .cancel(id: RequestingSnoozeOrdersID()),
      .cancel(id: RequestingUnsnoozeOrdersID()),
      .cancel(id: RequestingOrdersID()),
      .cancel(id: RequestingTripsID()),
      .cancel(id: RequestingHistoryID()),
      .cancel(id: RequestingIntegrationEntitiesID()),
      .cancel(id: RequestingPlacesID()),
      .cancel(id: RequestingCreatePlaceID()),
      .cancel(id: RequestingProfileID()),
      .cancel(id: RequestingTeamID()),
      .cancel(id: RequestingTokenID()),
      .cancel(id: RequestingVisitsID()),
      .init(value: .resetInProgressOrders)
    )
  case .switchToOrders, .switchToVisits, .resetInProgressOrders:
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
struct RequestingSnoozeOrdersID: Hashable {}
struct RequestingUnsnoozeOrdersID: Hashable {}
struct RequestingOrdersID: Hashable {}
struct RequestingTripsID: Hashable {}
struct RequestingHistoryID: Hashable {}
struct RequestingIntegrationEntitiesID: Hashable {}
struct RequestingPlacesID: Hashable {}
struct RequestingCreatePlaceID: Hashable {}
struct RequestingProfileID: Hashable {}
struct RequestingTeamID: Hashable {}
struct RequestingTokenID: Hashable {}
struct RequestingVisitsID: Hashable {}


let cancelOrderEffect = { (
  order: Order,
  cancelOrder: Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>,
  updateOrderNote: (Order.Note) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>,
  mainQueue: AnySchedulerOf<DispatchQueue>
) ->  Effect<RequestAction, Never> in
  changeOrderStatusEffect(.cancel, order, cancelOrder, updateOrderNote, mainQueue)
}

let completeOrderEffect = { (
  order: Order,
  completeOrder: Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>,
  updateOrderNote: (Order.Note) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>,
  mainQueue: AnySchedulerOf<DispatchQueue>
) ->  Effect<RequestAction, Never> in
  changeOrderStatusEffect(.complete, order, completeOrder, updateOrderNote, mainQueue)
}

let snoozeOrderEffect = { (
  order: Order,
  snoozeOrder: Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>,
  updateOrderNote: (Order.Note) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>,
  mainQueue: AnySchedulerOf<DispatchQueue>
) ->  Effect<RequestAction, Never> in
  changeOrderStatusEffect(.snooze, order, snoozeOrder, updateOrderNote, mainQueue)
}

let unsnoozeOrderEffect = { (
  order: Order,
  unsnoozeOrder: Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>,
  updateOrderNote: (Order.Note) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>,
  mainQueue: AnySchedulerOf<DispatchQueue>
) ->  Effect<RequestAction, Never> in
  changeOrderStatusEffect(.unsnooze, order, unsnoozeOrder, updateOrderNote, mainQueue)
}

private enum OrderStatus { case cancel, complete, snooze, unsnooze }

extension OrderStatus {
  func toFinishedAction(_ o: Order, _ r: Result<Terminal, APIError<Token.Expired>>) -> RequestAction {
    switch self {
    case .cancel:   return .orderCanceled(o, r)
    case .complete: return .orderCompleted(o, r)
    case .snooze:   return .orderSnoozed(o, r)
    case .unsnooze: return .orderUnsnoozed(o, r)
    }
  }

  func toFailedAction(_ o: Order, _ e: APIError<Token.Expired>) -> RequestAction {
    switch self {
    case .cancel:   return .orderCanceled(o, .failure(e))
    case .complete: return .orderCompleted(o, .failure(e))
    case .snooze:   return .orderSnoozed(o, .failure(e))
    case .unsnooze: return .orderUnsnoozed(o, .failure(e))
    }
  }

  var cancellableID: AnyHashable {
    switch self {
    case .cancel:   return RequestingCancelOrdersID()
    case .complete: return RequestingCompleteOrdersID()
    case .snooze:   return RequestingSnoozeOrdersID()
    case .unsnooze: return RequestingUnsnoozeOrdersID()
    }
  }
}

func getTeam(_ token: Token.Value, _ wh: WorkerHandle) -> Effect<Result<String, APIError<Token.Expired>>, Never> {
    return Effect(value: .success("")).flatMap { (result: Result<String, APIError<Token.Expired>>) -> Effect<Result<String, APIError<Token.Expired>>, Never> in
            .init(value: .success(""))
    }.eraseToEffect()
}

private let changeOrderStatusEffect = { (
  status: OrderStatus,
  order: Order,
  changeOrderStatus: Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>,
  updateOrderNote: (Order.Note) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>,
  mainQueue: AnySchedulerOf<DispatchQueue>
) ->  Effect<RequestAction, Never> in
  if let note = order.note {
    return updateOrderNote(note)
      .flatMap { (o: Order, r: Result<Terminal, APIError<Token.Expired>>) -> Effect<RequestAction, Never> in
        switch r {
        case     .success:    return changeOrderStatus.map(status.toFinishedAction)
        case let .failure(e): return .init(value: status.toFailedAction(o, e))
        }
      }
      .receive(on: mainQueue)
      .eraseToEffect()
      .cancellable(id: status.cancellableID, cancelInFlight: false)
  } else {
    return changeOrderStatus
      .receive(on: mainQueue)
      .map(status.toFinishedAction)
      .eraseToEffect()
      .cancellable(id: status.cancellableID, cancelInFlight: false)
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

let getTeamEffect = { (
  getTeam: Effect<Result<TeamValue?, APIError<Token.Expired>>, Never>,
  mainQueue: AnySchedulerOf<DispatchQueue>
) in
  getTeam
    .cancellable(id: RequestingTeamID())
    .receive(on: mainQueue)
    .map(RequestAction.teamUpdated)
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

let getVisitsEffect = { (
  getVisits: Effect<Result<VisitsData, APIError<Token.Expired>>, Never>,
  mainQueue: AnySchedulerOf<DispatchQueue>
) in
  getVisits
    .cancellable(id: RequestingVisitsID())
    .receive(on: mainQueue)
    .map(RequestAction.visitsUpdated)
    .eraseToEffect()
}

