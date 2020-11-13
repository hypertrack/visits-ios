import APIEnvironment
import Architecture
import Combine
import ComposableArchitecture
import Credentials
import DeepLinkEnvironment
import DeviceID
import DriverID
import HapticFeedbackEnvironment
import HyperTrackEnvironment
import ManualVisitsStatus
import MapEnvironment
import NetworkEnvironment
import NonEmpty
import PasteboardEnvironment
import Prelude
import PublishableKey
import RestorationState
import SDK
import StateRestorationEnvironment
import Tagged
import Visit
import UIKit

// MARK: - State

public struct AppState: Equatable {
  public var network: Network
  public var flow: AppFlow
  
  public static let initialState = AppState(network: .offline, flow: .created)
}

public enum AppFlow: Equatable {
  case created
  case appLaunching
  case noMotionServices
  case signIn(SignInState)
  case driverID(DriverID?, PublishableKey, ManualVisitsStatus?, ProcessingDeepLink?)
  case visits(Visits, PublishableKey, DriverID, DeviceID, SDKUnlockedStatus, Permissions, RequestInFlight?, ProcessingDeepLink?)
}

public enum RequestInFlight: Equatable {
  case refreshingVisits
}

public enum ProcessingDeepLink: Equatable {
  case waitingForDeepLink
  case waitingForTimerWith(PublishableKey, DriverID?, ManualVisitsStatus?)
  case waitingForSDKWith(PublishableKey, DriverID, ManualVisitsStatus?)
}

public enum SignInState: Equatable {
  case signingIn(Email, Password)
  case editingCredentials(These<Email, Password>?, Either<These<SignInFocus, SignInError>, ProcessingDeepLink>?)
}

public enum SignInFocus: Equatable { case email, password }

public typealias SignInError = Tagged<SignInErrorTag, NonEmptyString>
public enum SignInErrorTag {}

// MARK: - Action

public enum AppAction: Equatable {
  // OS
  case copyToPasteboard(NonEmptyString)
  case osFinishedLaunching
  case willEnterForeground
  // Sign In
  case cancelSignIn
  case emailChanged(Email?)
  case focusEmail
  case focusPassword
  case passwordChanged(Password?)
  case signIn
  case signedIn(Either<PublishableKey, NonEmptyString>)
  // DriverID
  case driverIDChanged(DriverID?)
  case setDriverID
  // Visits
  case addVisit
  case selectVisit(String)
  case updateVisits
  // Visit
  case cancelVisit
  case checkInVisit
  case checkOutVisit
  case deliveryNoteChanged(NonEmptyString?)
  case deselectVisit
  case focusDeliveryNote
  case openAppleMaps
  case pickUpVisit
  case visitsUpdated(Either<NonEmptySet<AssignedVisit>, NonEmptyString>)
  // Generic UI
  case dismissFocus
  // Deeplink
  case deepLinkOpened(NSUserActivity)
  case deepLinkTimerFired
  case receivedDeepLink(PublishableKey, DriverID?, ManualVisitsStatus?)
  // SDK
  case madeSDK(SDKStatus, Permissions)
  case openSettings
  case requestLocationPermissions
  case requestMotionPermissions
  case statusUpdated(SDKStatus, Permissions)
  case startTracking
  case stopTracking
  // Network
  case network(Network)
  // State
  case restoredState(Either<RestoredState, UntrackableReason>, Network)
  case stateRestored
}

// MARK: - Environment

public struct AppEnvironment {
  public var api: APIEnvironment
  public var deepLink: DeepLinkEnvironment
  public var hapticFeedback: HapticFeedbackEnvironment
  public var hyperTrack: HyperTrackEnvironment
  public var maps: MapEnvironment
  public var network: NetworkEnvironment
  public var pasteboard: PasteboardEnvironment
  public var stateRestoration: StateRestorationEnvironment
  
  public init(
    api: APIEnvironment,
    deepLink: DeepLinkEnvironment,
    hapticFeedback: HapticFeedbackEnvironment,
    hyperTrack: HyperTrackEnvironment,
    maps: MapEnvironment,
    network: NetworkEnvironment,
    pasteboard: PasteboardEnvironment,
    stateRestoration: StateRestorationEnvironment
  ) {
    self.api = api
    self.deepLink = deepLink
    self.hapticFeedback = hapticFeedback
    self.hyperTrack = hyperTrack
    self.maps = maps
    self.network = network
    self.pasteboard = pasteboard
    self.stateRestoration = stateRestoration
  }
}

// MARK: - Reducer

let networkReducer: Reducer<Network, AppAction, Void> = .toggleReducer(.online, .network(.online), .offline, .network(.offline))

public let appReducer: Reducer<AppState, AppAction, SystemEnvironment<AppEnvironment>> = Reducer.combine(
  networkReducer.pullback(state: \.network, action: .self, environment: constant(())),
  deepLinkReducer,
  stateRestorationReducer,
  // Sign In
  Reducer { state, action, environment in
    
    struct SignInID: Hashable {}
    
    switch state.flow {
    case let .signIn(.editingCredentials(emailAndPassword, focusAndDeeplink)):
      if case .right = focusAndDeeplink {
        return .none
      } else {
        let focusAndError: These<SignInFocus, SignInError>?
        if case let .left(f) = focusAndDeeplink {
          focusAndError = f
        } else {
          focusAndError = nil
        }
        switch action {
        case .emailChanged(.none):
          switch emailAndPassword {
          case .none, .some(.that): break
          case let .some(.both(_, password)):
            state.flow = .signIn(.editingCredentials(.that(password), focusAndDeeplink))
          case .some(.this):
            state.flow = .signIn(.editingCredentials(.none, focusAndDeeplink))
          }
          return .none
        case let .emailChanged(.some(e)):
          switch emailAndPassword {
          case .none:
            state.flow = .signIn(.editingCredentials(.this(e), focusAndDeeplink))
          case let .some(.both(_, password)):
            state.flow = .signIn(.editingCredentials(.both(e, password), focusAndDeeplink))
          case .some(.this):
            state.flow = .signIn(.editingCredentials(.this(e), focusAndDeeplink))
          case let .some(.that(password)):
            state.flow = .signIn(.editingCredentials(.both(e, password), focusAndDeeplink))
          }
          return .none
        case .focusEmail:
          switch focusAndError {
          case .none, .this:
            state.flow = .signIn(.editingCredentials(emailAndPassword, .left(.this(.email))))
          case let .some(.both(_, error)),
               let .some(.that(error)):
            state.flow = .signIn(.editingCredentials(emailAndPassword, .left(.both(.email, error))))
          }
          return .none
        case .focusPassword:
          switch focusAndError {
          case .none, .this:
            state.flow = .signIn(.editingCredentials(emailAndPassword, .left(.this(.password))))
          case let .some(.both(_, error)),
               let .some(.that(error)):
            state.flow = .signIn(.editingCredentials(emailAndPassword, .left(.both(.password, error))))
          }
          return .none
        case .passwordChanged(.none):
          switch emailAndPassword {
          case .none, .some(.this): break
          case let .some(.both(email, _)):
            state.flow = .signIn(.editingCredentials(.this(email), focusAndDeeplink))
          case .some(.that):
            state.flow = .signIn(.editingCredentials(.none, focusAndDeeplink))
          }
          return .none
        case let .passwordChanged(.some(p)):
          switch emailAndPassword {
          case .none:
            state.flow = .signIn(.editingCredentials(.that(p), focusAndDeeplink))
          case let .some(.both(email, _)):
            state.flow = .signIn(.editingCredentials(.both(email, p), focusAndDeeplink))
          case .some(.that):
            state.flow = .signIn(.editingCredentials(.that(p), focusAndDeeplink))
          case let .some(.this(email)):
            state.flow = .signIn(.editingCredentials(.both(email, p), focusAndDeeplink))
          }
          return .none
        case .signIn:
          if case let .both(e, p) = emailAndPassword {
            state.flow = .signIn(.signingIn(e, p))
            return environment.api
              .signIn(e, p)
              .map(AppAction.signedIn)
              .cancellable(id: SignInID(), cancelInFlight: true)
          } else {
            return .none
          }
        case .dismissFocus:
          switch focusAndError {
          case .none, .some(.this):
            state.flow = .signIn(.editingCredentials(emailAndPassword, .none))
            return .none
          case let .some(.both(_, e)),
               let .some(.that(e)):
            state.flow = .signIn(.editingCredentials(emailAndPassword, .left(.that(e))))
            return .none
          }
        default:
          return .none
        }
      }
    case let .signIn(.signingIn(e, p)):
      switch action {
      case .cancelSignIn:
        state.flow = .signIn(.editingCredentials(.both(e, p), nil))
        return .cancel(id: SignInID())
      case let .signedIn(.left(pk)):
        state.flow = .driverID(nil, pk, nil, nil)
        return .none
      case let .signedIn(.right(error)):
        state.flow = .signIn(.editingCredentials(.both(e, p), .left(.that(.init(rawValue: error)))))
        return .none
      default:
        return .none
      }
    default:
      return .none
    }
  },
  // DriverID
  Reducer { state, action, environment in
    switch state.flow {
    case let .driverID(drID, pk, mvs, .none):
      switch action {
      case let .driverIDChanged(newDrID):
        state.flow = .driverID(newDrID, pk, mvs, .none)
        return .none
      case .setDriverID:
        if let drID = drID {
          return environment.hyperTrack
            .makeSDK(pk)
            .map(AppAction.madeSDK)
        }
        return .none
      case .madeSDK(.locked, _):
        state.flow = .noMotionServices
        return .none
      case let .madeSDK(.unlocked(deID, us), p):
        if let drID = drID {
          let visits: Visits
          switch mvs {
          case .none:
            visits = .default
          case .hideManualVisits:
            visits = .assigned([])
          case .showManualVisits:
            visits = .mixed([])
          }
          state.flow = .visits(visits, pk, drID, deID, us, p, nil, nil)
          return .merge(
            environment.hyperTrack
              .subscribeToStatusUpdates()
              .map(AppAction.statusUpdated),
            environment.hyperTrack
              .setDriverID(drID)
              .fireAndForget()
          )
        } else {
          return .none
        }
      default:
        return .none
      }
    default:
      return .none
    }
  },
  // Visits
  Reducer { state, action, environment in
    struct RefreshingVisitsID: Hashable {}
    
    switch state.flow {
    case let .visits(v, pk, drID, deID, us, p, r, d):
      switch action {
      case .willEnterForeground, .updateVisits:
        if r != .refreshingVisits {
          state.flow = .visits(filterOutOldVisits(v, now: environment.date()), pk, drID, deID, us, p, .refreshingVisits, d)
          return environment.api
            .getVisits(pk, deID)
            .cancellable(id: RefreshingVisitsID())
            .map(AppAction.visitsUpdated)
        }
        return .none
      case let .copyToPasteboard(s):
        return .merge(
          environment.hapticFeedback
            .notifySuccess()
            .fireAndForget(),
          environment.pasteboard
          .copyToPasteboard(s)
          .fireAndForget()
        )
      case .addVisit:
        switch v {
        case let .mixed(vs):
          let m = ManualVisit(
            id: ManualVisit.ID(rawValue: NonEmptyString(stringLiteral: environment.uuid().uuidString)),
            createdAt: environment.date(),
            geotagSent: .notSent,
            noteFieldFocused: false
          )
          state.flow = .visits(.selectedMixed(Visit.left(m), vs), pk, drID, deID, us, p, r, d)
          return .none
        default:
          return .none
        }
      case let .selectVisit(str):
        switch v {
        case let .mixed(ms):
          var msSel = ms
          if let i = msSel.firstIndex(where: { vis in
            switch vis {
            case let .left(manual):
              if manual.id.rawValue.rawValue == str {
                return true
              } else {
                return false
              }
            case let .right(assigned):
              if assigned.id.rawValue.rawValue == str {
                return true
              } else {
                return false
              }
            }
          }) {
            let selected = msSel.remove(at: i)
            state.flow = .visits(.selectedMixed(selected, msSel), pk, drID, deID, us, p, r, d)
            return .none
          } else {
            return .none
          }
        case let .assigned(aas):
          var msSel = aas
          if let i = msSel.firstIndex(where: { $0.id.rawValue.rawValue == str }) {
            let selected = msSel.remove(at: i)
            state.flow = .visits(.selectedAssigned(selected, msSel), pk, drID, deID, us, p, r, d)
            return .none
          } else {
            return .none
          }
        case .selectedMixed, .selectedAssigned:
          return .none
        }
      case .cancelVisit:
        switch v {
        case let .selectedAssigned(a, aas) where a.geotagSent == .checkedIn:
          var a = a
          a.geotagSent = .cancelled(environment.date())
          state.flow = .visits(.selectedAssigned(a, aas), pk, drID, deID, us, p, r, d)
          return .merge(
            environment.hyperTrack
              .addGeotag(.cancel(.init(id: a.id, source: a.source, deliveryNote: a.deliveryNote)))
              .fireAndForget(),
            environment.hapticFeedback
              .notifySuccess()
              .fireAndForget()
          )
        case let .selectedMixed(.right(a), vs) where a.geotagSent == .checkedIn:
          var a = a
          a.geotagSent = .cancelled(environment.date())
          state.flow = .visits(.selectedMixed(.right(a), vs), pk, drID, deID, us, p, r, d)
          return .merge(
            environment.hyperTrack
              .addGeotag(.cancel(.init(id: a.id, source: a.source, deliveryNote: a.deliveryNote)))
              .fireAndForget(),
            environment.hapticFeedback
              .notifySuccess()
              .fireAndForget()
          )
        default:
          return .none
        }
      case .checkInVisit:
        switch v {
        case let .selectedAssigned(a, aas) where a.geotagSent == .pickedUp || a.geotagSent == .notSent:
          var a = a
          a.geotagSent = .checkedIn
          state.flow = .visits(.selectedAssigned(a, aas), pk, drID, deID, us, p, r, d)
          return .merge(
            environment.hyperTrack
              .addGeotag(.checkIn(.right(.init(id: a.id, source: a.source))))
              .fireAndForget(),
            environment.hapticFeedback
              .notifySuccess()
              .fireAndForget()
          )
        case let .selectedMixed(.right(a), vs) where a.geotagSent == .pickedUp || a.geotagSent == .notSent:
          var a = a
          a.geotagSent = .checkedIn
          state.flow = .visits(.selectedMixed(.right(a), vs), pk, drID, deID, us, p, r, d)
          return .merge(
            environment.hyperTrack
              .addGeotag(.checkIn(.right(.init(id: a.id, source: a.source))))
              .fireAndForget(),
            environment.hapticFeedback
              .notifySuccess()
              .fireAndForget()
          )
        case let .selectedMixed(.left(m), vs) where m.geotagSent == .notSent:
          var m = m
          m.geotagSent = .checkedIn
          state.flow = .visits(.selectedMixed(.left(m), vs), pk, drID, deID, us, p, r, d)
          return .merge(
            environment.hyperTrack
              .addGeotag(.checkIn(.left(m.id)))
              .fireAndForget(),
            environment.hapticFeedback
              .notifySuccess()
              .fireAndForget()
          )
        default:
          return .none
        }
      case .checkOutVisit:
        switch v {
        case let .selectedAssigned(a, aas) where a.geotagSent == .checkedIn:
          var a = a
          a.geotagSent = .checkedOut(environment.date())
          state.flow = .visits(.selectedAssigned(a, aas), pk, drID, deID, us, p, r, d)
          return .merge(
            environment.hyperTrack
              .addGeotag(.checkOut(.right(.init(id: a.id, source: a.source, deliveryNote: a.deliveryNote))))
              .fireAndForget(),
            environment.hapticFeedback
              .notifySuccess()
              .fireAndForget()
          )
        case let .selectedMixed(.right(a), vs) where a.geotagSent == .checkedIn:
          var a = a
          a.geotagSent = .checkedOut(environment.date())
          state.flow = .visits(.selectedMixed(.right(a), vs), pk, drID, deID, us, p, r, d)
          return .merge(
            environment.hyperTrack
              .addGeotag(.checkOut(.right(.init(id: a.id, source: a.source, deliveryNote: a.deliveryNote))))
              .fireAndForget(),
            environment.hapticFeedback
              .notifySuccess()
              .fireAndForget()
          )
        case let .selectedMixed(.left(m), vs) where m.geotagSent == .checkedIn:
          var m = m
          m.geotagSent = .checkedOut(environment.date())
          state.flow = .visits(.selectedMixed(.left(m), vs), pk, drID, deID, us, p, r, d)
          return .merge(
            environment.hyperTrack
              .addGeotag(.checkOut(.left(.init(id: m.id, deliveryNote: m.deliveryNote))))
              .fireAndForget(),
            environment.hapticFeedback
              .notifySuccess()
              .fireAndForget()
          )
        default:
          return .none
        }
      case let .deliveryNoteChanged(n):
        switch v {
        case let .selectedAssigned(a, aas):
          var a = a
          if let n = n {
            a.deliveryNote = .init(rawValue: n)
          } else {
            a.deliveryNote = nil
          }
          state.flow = .visits(.selectedAssigned(a, aas), pk, drID, deID, us, p, r, d)
          return .none
        case let .selectedMixed(.left(m), vs):
          var m = m
          if let n = n {
            m.deliveryNote = .init(rawValue: n)
          } else {
            m.deliveryNote = nil
          }
          state.flow = .visits(.selectedMixed(.left(m), vs), pk, drID, deID, us, p, r, d)
          return .none
        case let .selectedMixed(.right(a), vs):
          var a = a
          if let n = n {
            a.deliveryNote = .init(rawValue: n)
          } else {
            a.deliveryNote = nil
          }
          state.flow = .visits(.selectedMixed(.right(a), vs), pk, drID, deID, us, p, r, d)
          return .none
        default:
          return .none
        }
      case .deselectVisit:
        switch v {
        case .mixed, .assigned:
          return .none
        case let .selectedMixed(.left(m), vs) where m.geotagSent == .notSent:
          state.flow = .visits(.mixed(vs), pk, drID, deID, us, p, r, d)
          return .none
        case let .selectedMixed(s, vs):
          var res = vs
          res.insert(s)
          state.flow = .visits(.mixed(res), pk, drID, deID, us, p, r, d)
          return .none
        case let .selectedAssigned(s, aas):
          var res = aas
          res.insert(s)
          state.flow = .visits(.assigned(res), pk, drID, deID, us, p, r, d)
          return .none
        }
      case .focusDeliveryNote:
        switch v {
        case let .selectedAssigned(a, aas):
          var a = a
          a.noteFieldFocused = true
          state.flow = .visits(.selectedAssigned(a, aas), pk, drID, deID, us, p, r, d)
          return .none
        case let .selectedMixed(.left(m), vs):
          var m = m
          m.noteFieldFocused = true
          state.flow = .visits(.selectedMixed(.left(m), vs), pk, drID, deID, us, p, r, d)
          return .none
        case let .selectedMixed(.right(a), vs):
          var a = a
          a.noteFieldFocused = true
          state.flow = .visits(.selectedMixed(.right(a), vs), pk, drID, deID, us, p, r, d)
          return .none
        default:
          return .none
        }
      case .openAppleMaps:
        switch v {
        case let .selectedMixed(.right(a), _),
             let .selectedAssigned(a, _):
          let add: Either<AssignedVisit.FullAddress, AssignedVisit.Street>?
          switch a.address {
          case .none:
            add = .none
          case let .some(.both(_, f)),
               let .some(.that(f)):
            add = .left(f)
          case let .some(.this(a)):
            add = .right(a)
          }
          return environment.maps
            .openMap(a.location, add)
            .fireAndForget()
        default:
          return .none
        }
      case .pickUpVisit:
        switch v {
        case let .selectedAssigned(a, aas) where a.geotagSent == .notSent:
          var a = a
          a.geotagSent = .pickedUp
          state.flow = .visits(.selectedAssigned(a, aas), pk, drID, deID, us, p, r, d)
          return .merge(
            environment.hyperTrack
              .addGeotag(.pickUp(a.id, a.source))
              .fireAndForget(),
            environment.hapticFeedback
              .notifySuccess()
              .fireAndForget()
          )
        case let .selectedMixed(.right(a), vs) where a.geotagSent == .notSent:
          var a = a
          a.geotagSent = .pickedUp
          state.flow = .visits(.selectedMixed(.right(a), vs), pk, drID, deID, us, p, r, d)
          return .merge(
            environment.hyperTrack
              .addGeotag(.pickUp(a.id, a.source))
              .fireAndForget(),
            environment.hapticFeedback
              .notifySuccess()
              .fireAndForget()
          )
        default:
          return .none
        }
      case .dismissFocus:
        switch v {
        case let .selectedAssigned(a, aas):
          var a = a
          a.noteFieldFocused = false
          state.flow = .visits(.selectedAssigned(a, aas), pk, drID, deID, us, p, r, d)
          return .none
        case let .selectedMixed(.left(m), vs):
          var m = m
          m.noteFieldFocused = false
          state.flow = .visits(.selectedMixed(.left(m), vs), pk, drID, deID, us, p, r, d)
          return .none
        case let .selectedMixed(.right(a), vs):
          var a = a
          a.noteFieldFocused = false
          state.flow = .visits(.selectedMixed(.right(a), vs), pk, drID, deID, us, p, r, d)
          return .none
        default:
          return .none
        }
      case .openSettings:
        return environment.hyperTrack
          .openSettings()
          .fireAndForget()
      case .requestLocationPermissions:
        return environment.hyperTrack
          .requestLocationPermissions()
          .fireAndForget()
      case .requestMotionPermissions:
        return environment.hyperTrack
          .requestMotionPermissions()
          .map(AppAction.statusUpdated)
      case let .statusUpdated(s, p):
        switch s {
        case .locked:
          state.flow = .noMotionServices
          return .none
        case let .unlocked(deID, us):
          state.flow = .visits(v, pk, drID, deID, us, p, r, d)
          return .none
        }
      case .startTracking:
        if r != .refreshingVisits {
          state.flow = .visits(filterOutOldVisits(v, now: environment.date()), pk, drID, deID, us, p, .refreshingVisits, d)
          return .merge(
            environment.hyperTrack
              .startTracking()
              .fireAndForget(),
            environment.api
              .getVisits(pk, deID)
              .cancellable(id: RefreshingVisitsID())
              .map(AppAction.visitsUpdated)
          )
        }
        return environment.hyperTrack
          .startTracking()
          .fireAndForget()
      case .stopTracking:
        if r == .refreshingVisits {
          state.flow = .visits(v, pk, drID, deID, us, p, .none, d)
          return .merge(
            environment.hyperTrack
              .stopTracking()
              .fireAndForget(),
            .cancel(id: RefreshingVisitsID())
          )
        }
        return environment.hyperTrack
          .stopTracking()
          .fireAndForget()
      case let .visitsUpdated(.left(vs)):
        state.flow = .visits(mergeVisits(vs: v, with: vs), pk, drID, deID, us, p, .none, d)
        return .none
      case .visitsUpdated(.right):
        state.flow = .visits(v, pk, drID, deID, us, p, .none, d)
        return .none
      default:
        return .none
      }
    default:
      return .none
    }
  }
)
.autosave()






func mergeVisits(vs: Visits, with aas: NonEmptySet<AssignedVisit>) -> Visits {
  switch vs {
  case var .mixed(v):
    for a in aas.rawValue {
      if !v.contains(where: sameAssignedID(a.id)) {
        v.insert(.right(a))
      }
    }
    return .mixed(v)
  case var .assigned(v):
    for a in aas.rawValue {
      if !v.contains(where: { $0.id == a.id }) {
        v.insert(a)
      }
    }
    return .assigned(v)
  case .selectedMixed(let s, var v):
    var mutV = v
    mutV.insert(s)
    for a in aas.rawValue {
      if !mutV.contains(where: sameAssignedID(a.id)) {
        v.insert(.right(a))
      }
    }
    return .selectedMixed(s, v)
  case .selectedAssigned(let s, var v):
    var mutV = v
    mutV.insert(s)
    for a in aas.rawValue {
      if !mutV.contains(where: { $0.id == a.id }) {
        v.insert(a)
      }
    }
    return .selectedAssigned(s, v)
  }
}

func sameAssignedID(_ id: AssignedVisit.ID) -> (Visit) -> Bool {
  { visit in
    switch visit {
    case .left:
      return false
    case let .right(a) where a.id == id:
      return true
    case .right:
      return false
    }
  }
}


//func mergeVisit(local: AssignedVisit, remote: AssignedVisit) -> AssignedVisit {
//  var remote = remote
//  remote.geotagSent = local.geotagSent
//  remote.a
//}

//func mergeMixedVisits(local: Set<Visits>, remote: NonEmptySet<AssignedVisit>) -> Set
