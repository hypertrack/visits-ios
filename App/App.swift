import Combine

import ComposableArchitecture
import HyperTrack

import Delivery
import Deeplink
import Deliveries
import DriverID
import Location
import Motion
import Notification
import Prelude
import Reachability
import Restoration
import SignIn
import Tracking


// MARK: - State

public struct AppState: Equatable {
  var networkStatus: NetworkStatus
  var monitoringReachability: Bool
  var userStatus: UserStatus
  var services: Services
}

enum NetworkStatus: Equatable {
  case online(RequestStatus)
  case offline
}

struct RequestStatus: Equatable {
  var deliveriesRequestStatus: Bool
}

enum UserStatus: Equatable {
  case new(Credentials)
  case authenticated(Authenticated)
  case registered(Registered)
}

struct Authenticated: Equatable {
  var publishableKey: NonEmptyString
  var registration: DriverIDState
}

struct Registered: Equatable {
  var user: User
}

struct User: Equatable {
  var deliveries: [Deliveries.DeliveryModel]
  var driverID: NonEmptyString
  var publishableKey: NonEmptyString
  var selectedDelivery: Deliveries.DeliveryModel?
  var trackingStatus: TrackingStatus
  var deliveryNote: String
  var isNoteFieldFocused: Bool
  var completedDeliveries: [NonEmptyString]
  var alertContent: AlertContent
}

struct Services: Equatable {
  var location: LocationState
  var motion: MotionState
}

public enum Restoration {
  case failed
  case publishableKey(NonEmptyString)
  case user(publishableKey: NonEmptyString, driverID: NonEmptyString, completedDeliveries: [NonEmptyString])
}

extension AppState {
  public static func initialState(
    locationPermissions: LocationPermissions,
    motionPermissions: MotionState,
    restoration: Restoration) -> AppState {
    let isOnline = NetworkStatus.online(RequestStatus(deliveriesRequestStatus: false))
    let monitoringReachability = false
    let services = Services(
      location: LocationState(monitoring: false, permissions: locationPermissions),
      motion: motionPermissions
    )
    switch restoration {
    case .failed:
      return .init(
        networkStatus: isOnline, monitoringReachability: false,
        userStatus: .new(.incomplete(.initialState)),
        services: services
      )
    case let .publishableKey(pk):
      return .init(
        networkStatus: isOnline,
        monitoringReachability: monitoringReachability,
        userStatus: .authenticated(.init(publishableKey: pk, registration: .initialState)),
        services: services
      )
    case let .user(publishableKey, driverID, completedDeliveries):
      return .init(
        networkStatus: isOnline,
        monitoringReachability: monitoringReachability,
        userStatus: .registered(.init(user: .init(deliveries: [], driverID: driverID, publishableKey: publishableKey, trackingStatus: .notTracking(freeLimitReached: false), deliveryNote: "", isNoteFieldFocused: false, completedDeliveries: completedDeliveries, alertContent: .none))),
        services: services
      )
    }
  }
}

extension AppState {
  var signInState: SignInState {
    get {
      let isOnline: Bool
      switch networkStatus {
      case .online: isOnline = true
      case .offline: isOnline = false
      }
      if case let .new(credentials) = userStatus {
        return .init(credentials: credentials, isOnline: isOnline)
      } else {
        return .initialState(isOnline: isOnline)
      }
    }
    set {
      userStatus = .new(newValue.credentials)
      if networkStatus == .offline, newValue.isOnline {
        networkStatus = .online(RequestStatus(deliveriesRequestStatus: false))
      } else if !newValue.isOnline {
        networkStatus = .offline
      }
    }
  }
  
  var driverIDState: DriverIDState {
    get {
      if case let .authenticated(auth) = userStatus {
        return auth.registration
      } else {
        return .initialState
      }
    }
    set {
      if case let .authenticated(auth) = userStatus {
        userStatus = .authenticated(auth |> \.registration .~ newValue)
      }
    }
  }
  
  var void: Void {
    get { return () }
    set { }
  }
}

// MARK: - Action

public enum AppAction: Equatable {
  case appAppeared
  case becameTrackable
  case cancelDeliveriesUpdate
  case driverID(DriverIDAction)
  case enteredForeground
  case handleDeliveriesUpdateError(NonEmptyString)
  case location(LocationActionAdapter)
  case motion(MotionActionAdapter)
  case reachability(ReachabilityAction)
  case receivedDeeplink(String?)
  case updateDeliveries
  case selectDelivery(Deliveries.DeliveryModel)
  case signIn(SignInAction)
  case trackingStarted
  case trackingStopped
  case trialEnded
  case handleDeliveriesUpdate([Deliveries.DeliveryModel])
  case updateMetadata
  case deselectDelivery
  case openAppleMaps
  case copyDeliverySection(String)
  case completeDelivery
  case focusDeliveryNote
  case changeDeliveryNote(String)
  case saveCompletedDeliveries
  case sendDeliveryNote
  case unfocusDeliveryNote
  case alertPresentingFinished
}

// MARK: - Environment

public typealias AppEnvironment = (
  deeplinkEnvironment: DeeplinkEnvironment,
  deliveriesEnvironment: DeliveriesEnvironment,
  locationEnvironment: LocationEnvironment,
  motionEnvironment: MotionEnvironment,
  notificationEnvironment: NotificationEnvironment,
  reachabilityEnvironment: ReachabilityEnvironment,
  restorationEnvironment: RestorationEnvironment,
  signInEnvironment: SignInEnvironment,
  trackingEnvironment: TrackingEnvironment,
  deliveryEnvironment: DeliveryEnvironment
)

// MARK: - Reducer

public let appReducer: Reducer<AppState, AppAction, SystemEnvironment<AppEnvironment>> = .combine(
  completedDeliveryClenupReducer,
  deliveryGlueReducer,
  deliveryReducer.optional.pullback(
    state: \AppState.deliveryState,
    action: AppAction.deliveryCasePath,
    environment: { $0.map(\.deliveryEnvironment) }
  ),
  deeplinkReducer.optional.pullback(
    state: \AppState.deeplinkable,
    action: AppAction.deeplinkCasePath,
    environment: { $0.map(\.deeplinkEnvironment) }
  ),
  deliveriesReducer.optional.pullback(
    state: \AppState.deliveriesState,
    action: AppAction.deliveriesCasePath,
    environment: { $0.map(\.deliveriesEnvironment) }
  ),
  driverIDReducer.pullback(
    state: \AppState.driverIDState,
    action: /AppAction.driverID,
    environment: const(())
  ),
  driverIDGlueReducer,
  locationReducer.pullback(
    state: \AppState.services.location,
    action: AppAction.locationCasePath,
    environment: { $0.map(\.locationEnvironment) }
  ),
  motionReducer.pullback(
    state: \AppState.services.motion,
    action: AppAction.motionCasePath,
    environment: { $0.map(\.motionEnvironment) }
  ),
  notificationReducer.pullback(
    state: \AppState.void,
    action: AppAction.notificationCasePath,
    environment: { $0.map(\.notificationEnvironment) }
  ),
  reachabilityReducer.pullback(
    state: \AppState.reachability,
    action: AppAction.reachabilityCasePath,
    environment: { $0.map(\.reachabilityEnvironment) }
  ),
  restorationReducer.pullback(
    state: \AppState.restoration,
    action: AppAction.restorationCasePath,
    environment: { $0.map(\.restorationEnvironment) }
  ),
  signInReducer.pullback(
    state: \AppState.signInState,
    action: /AppAction.signIn,
    environment: { $0.map(\.signInEnvironment) }
  ),
  signInGlueReducer,
  trackingReducer.optional.pullback(
    state: \AppState.tracking,
    action: AppAction.trackingCasePath,
    environment: { $0.map(\.trackingEnvironment) }
  )
)

extension Reducer where State == AppState, Action == AppAction, Environment == SystemEnvironment<AppEnvironment> {
  public var notifyWhenBecomesTrackable: Reducer {
    .init { state, action, environment in
      let trackableBefore = state.trackable
      let effects = self.callAsFunction(&state, action, environment)
      let trackableAfter = state.trackable
      if !trackableBefore, trackableAfter {
        return .concatenate(effects, Effect(value: .becameTrackable))
      }
      return effects
    }
  }
}

let signInGlueReducer = Reducer<AppState, AppAction, SystemEnvironment<AppEnvironment>> { state, action, _ in
  if case let .signIn(.done(.signedIn(publishableKey))) = action,
    case .new = state.userStatus {
    state = state |> \.userStatus .~ .authenticated(
      .init(publishableKey: publishableKey, registration: .initialState)
    )
  }
  return .none
}

let driverIDGlueReducer = Reducer<AppState, AppAction, SystemEnvironment<AppEnvironment>> { state, action, _ in
  if case let .driverID(.register(driverID)) = action,
    case let .authenticated(status) = state.userStatus {
    state.userStatus = .registered(
      Registered(
        user: User(
          deliveries: [],
          driverID: driverID,
          publishableKey: status.publishableKey,
          trackingStatus: .notTracking(freeLimitReached: false),
          deliveryNote: "",
          isNoteFieldFocused: false,
          completedDeliveries: [],
          alertContent: .none
        )
      )
    )
  }
  return .none
}

let completedDeliveryClenupReducer = Reducer<AppState, AppAction, SystemEnvironment<AppEnvironment>> { state, action, _ in
  if case let .registered(reg) = state.userStatus,
    case let .handleDeliveriesUpdate(deliveries) = action {
    let completed = deliveries
      .filter { reg.user.completedDeliveries.contains($0.id) }
      . map { $0.id }
    state.userStatus = state.userStatus
      |> /UserStatus.registered >>> \.user.completedDeliveries .- completed
    return Effect(value: AppAction.saveCompletedDeliveries)
  }
  return .none
}

let deliveryGlueReducer = Reducer<AppState, AppAction, SystemEnvironment<AppEnvironment>> { state, action, _ in
  if case let .registered(reg) = state.userStatus {
    
    let cleanupDelivery = /UserStatus.registered >>> \.user.deliveryNote .- ""
      <> /UserStatus.registered >>> \.user.isNoteFieldFocused .- false
      <> /UserStatus.registered >>> \.user.alertContent .- .none
    
    if case .deselectDelivery = action {
      state.userStatus = state.userStatus
        |> /UserStatus.registered >>> \.user.selectedDelivery .- nil
        <> cleanupDelivery
    } else if case let .selectDelivery(delivery) = action {
      state.userStatus = state.userStatus
      |> /UserStatus.registered >>> \.user.selectedDelivery .- delivery
      <> cleanupDelivery
    }
  }
  return .none
}
