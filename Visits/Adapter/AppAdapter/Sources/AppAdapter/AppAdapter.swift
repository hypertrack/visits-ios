import App
import AppScreen
import BlockerScreen
import ComposableArchitecture
import DeepLinkScreen
import DriverIDScreen
import LoadingScreen
import MapScreen
import Prelude
import SignInScreen
import Visit
import VisitScreen
import VisitsScreen



// MARK: - Life Cycle

public enum LifeCycleAction {
  case finishedLaunching
  case deepLinkOpened(NSUserActivity)
  case receivedPushNotification
  case willEnterForeground
}

public extension ViewStore where State == Prelude.Unit, Action == LifeCycleAction {
  static func lifeCycleViewStore(from store: Store<AppState, AppAction>) -> ViewStore {
    ViewStore(
      store.scope(
        state: { _ in unit },
        action: { a in
          switch a {
          case let .deepLinkOpened(a):    return .deepLinkOpened(a)
          case .finishedLaunching:        return .osFinishedLaunching
          case .receivedPushNotification: return .receivedPushNotification
          case .willEnterForeground:      return .willEnterForeground
          }
        }
      )
    )
  }
}

public func deepLink(from userActivities: Set<NSUserActivity>) -> NSUserActivity? {
  for activity in userActivities {
    if activity.webpageURL != nil {
      return activity
    }
  }
  return nil
}

// MARK: - App Screen

public extension Store where State == AppScreen.State, Action == AppScreen.Action {
  static func appScreenStore(from store: Store<AppState, AppAction>) -> Store {
    store.scope(state: fromAppState, action: toAppAction)
  }
}

func fromAppState(_ appState: AppState) -> AppScreen.State {
  switch appState.flow {
  case .created, .appLaunching: return .loading
  case .noMotionServices: return .blocker(.noMotionServices)
  case let .signIn(.editingCredentials(_, .right(p))): return processingDeepLink(p)
  case let .signIn(s):
    return .signIn(
      .init(
        buttonState: buttonState(from: s),
        email: email(from: s),
        errorMessage: errorMessage(from: s),
        fieldInFocus: fieldInFocus(from: s),
        password: password(from: s),
        signingIn: signingIn(from: s)
      )
    )
  case let .driverID(_, _, _, .some(p)): return processingDeepLink(p)
  case let .driverID(.some(drID), _, _, _):
    return .driverID(.init(driverID: drID.rawValue.rawValue, buttonDisabled: false))
  case .driverID: return .driverID(.init(driverID: "", buttonDisabled: true))
  case let .visits(_, _, _, _, _, _, _, _, _, _, .some(p)): return processingDeepLink(p)
  case let .visits(v, h, s, pk, _, deID, us, p, r, ps, _):
    switch (us, p.locationAccuracy, p.locationPermissions, p.motionPermissions, ps) {
    case (_, _, .disabled, _, _):                return .blocker(.locationDisabled)
    case (_, _, .denied, _, _):                  return .blocker(.locationDenied)
    case (_, _, .restricted, _, _):              return .blocker(.locationRestricted)
    case (_, _, .notDetermined, _, _):           return .blocker(.locationNotDetermined)
    case (_, .reduced, _, _, _):                 return .blocker(.locationReduced)
    case (_, _, _, .disabled, _):                return .blocker(.motionDisabled)
    case (_, _, _, .denied, _):                  return .blocker(.motionDenied)
    case (_, _, _, .notDetermined, _):           return .blocker(.motionNotDetermined)
    case (_, _, _, _, .dialogSplash(.notShown)): return .blocker(.pushNotShown)
    case (.deleted, _, _, _, _):                 return .blocker(.deleted(deID.rawValue.rawValue))
    case (.invalidPublishableKey, _, _, _, _):   return .blocker(.invalidPublishableKey(deID.rawValue.rawValue))
    case (.stopped, _, _, _, _):                 return .blocker(.stopped)
    case (.running, .full, .authorized, .authorized, .dialogSplash(.shown)):
      let networkAvailable = appState.network == .online
      let refreshingVisits: Bool
      switch r {
      case .none, .some(.that):
        refreshingVisits = false
      case .some(.this), .some(.both):
        refreshingVisits = true
      }
      let mapVisitsList = mapVisits(from: assignedVisits(from: v))
      switch v {
      case let .mixed(visits):
        let (pending, visited, completed, canceled) = visitHeaders(from: Array(visits))
        return .visits(.visits(.init(pending: pending, visited: visited, completed: completed, canceled: canceled, isNetworkAvailable: networkAvailable, refreshing: refreshingVisits, showManualVisits: true, deviceID: deID.rawValue.rawValue, publishableKey: pk.rawValue.rawValue)), h, mapVisitsList, s)
      case let .assigned(assignedVisits):
        let (pending, visited, completed, canceled) = visitHeaders(from: assignedVisits.map(Either.right))
        return .visits(.visits(.init(pending: pending, visited: visited, completed: completed, canceled: canceled, isNetworkAvailable: networkAvailable, refreshing: refreshingVisits, showManualVisits: false, deviceID: deID.rawValue.rawValue, publishableKey: pk.rawValue.rawValue)), h, mapVisitsList, s)
      case let .selectedMixed(selectedVisit, _):
        return .visits(.visit(visitScreen(from: selectedVisit, pk: pk.rawValue.rawValue, dID: deID.rawValue.rawValue)), h, mapVisitsList, s)
      case let .selectedAssigned(selectedAssignedVisit, _):
        return .visits(.visit(visitScreen(from: .right(selectedAssignedVisit), pk: pk.rawValue.rawValue, dID: deID.rawValue.rawValue)), h, mapVisitsList, s)
      }
    }
  }
}


func toAppAction(_ appScreenAction: AppScreen.Action) -> AppAction {
  switch appScreenAction {
  case .signIn(.cancelSignInTapped): return .cancelSignIn
  case let .signIn(.emailChanged(e)) where e.isEmpty: return .emailChanged(nil)
  case let .signIn(.emailChanged(e)): return .emailChanged(.init(stringLiteral: e))
  case .signIn(.emailEnterKeyboardButtonTapped): return .focusPassword
  case .signIn(.emailTapped): return .focusEmail
  case let .signIn(.passwordChanged(p)) where p.isEmpty: return .passwordChanged(nil)
  case let .signIn(.passwordChanged(p)): return .passwordChanged(.init(stringLiteral: p))
  case .signIn(.passwordEnterKeyboardButtonTapped): return .signIn
  case .signIn(.passwordTapped): return .focusPassword
  case .signIn(.signInTapped): return .signIn
  case .signIn(.tappedOutsideFocus): return .dismissFocus
  case .driverID(.buttonTapped): return .setDriverID
  case let .driverID(.driverIDChanged(d)) where d.isEmpty: return .driverIDChanged(nil)
  case let .driverID(.driverIDChanged(d)): return .driverIDChanged(.init(stringLiteral: d))
  case .driverID(.nextEnterKeyboardButtonTapped): return .setDriverID
  case .blocker(.deletedButtonTapped): return .startTracking
  case .blocker(.invalidPublishableKeyButtonTapped): return .startTracking
  case .blocker(.stoppedButtonTapped): return .startTracking
  case .blocker(.locationDeniedButtonTapped): return .openSettings
  case .blocker(.locationDisabledButtonTapped): return .openSettings
  case .blocker(.locationNotDeterminedButtonTapped): return .requestLocationPermissions
  case .blocker(.locationRestrictedButtonTapped): return .openSettings
  case .blocker(.locationReducedButtonTapped): return .openSettings
  case .blocker(.motionDeniedButtonTapped): return .openSettings
  case .blocker(.motionDisabledButtonTapped): return .openSettings
  case .blocker(.motionNotDeterminedButtonTapped): return .requestMotionPermissions
  case .blocker(.pushNotShownButtonTapped): return .requestPushAuthorization
  case .visits(.addVisitButtonTapped): return .addVisit
  case .visits(.clockOutButtonTapped): return .stopTracking
  case .visits(.refreshButtonTapped): return .updateVisits
  case let .visits(.visitTapped(id)): return .selectVisit(id)
  case .visit(.backButtonTapped): return .deselectVisit
  case .visit(.cancelButtonTapped): return .cancelVisit
  case .visit(.checkInButtonTapped): return .checkInVisit
  case .visit(.checkOutButtonTapped): return .checkOutVisit
  case let .visit(.copyTextPressed(t)): return .copyToPasteboard(t)
  case .visit(.mapTapped): return .openAppleMaps
  case .visit(.noteEnterKeyboardButtonTapped): return .dismissFocus
  case let .visit(.noteFieldChanged(d)) where d.isEmpty: return .visitNoteChanged(nil)
  case let .visit(.noteFieldChanged(d)): return .visitNoteChanged(.init(stringLiteral: d))
  case .visit(.noteTapped): return .focusVisitNote
  case .visit(.pickedUpButtonTapped): return .pickUpVisit
  case .visit(.tappedOutsideFocusedTextField): return .dismissFocus
  case .tab(.map): return .switchToMap
  case .tab(.visits): return .switchToVisits
  case let .map(id): return .selectVisit(id)
  }
}

func processingDeepLink(_ p: ProcessingDeepLink) -> AppScreen.State {
  switch p {
  case .waitingForDeepLink, .waitingForTimerWith:
    return .deepLink(.init(time: 5, work: .connecting))
  case .waitingForSDKWith:
    return .deepLink(.init(time: 5, work: .sdk))
  }
}

func email(from s: SignInState) -> String {
  switch s {
  case let .signingIn(e, _),
       let .editingCredentials(.both(e, _), _),
       let .editingCredentials(.this(e), _):
    return e.rawValue.rawValue
  default: return ""
  }
}

func password(from s: SignInState) -> String {
  switch s {
  case let .signingIn(_, p),
       let .editingCredentials(.both(_, p), _),
       let .editingCredentials(.that(p), _):
    return p.rawValue.rawValue
  default: return ""
  }
}

func buttonState(from s: SignInState) -> SignInScreen.State.ButtonState {
  switch s {
  case .signingIn: return .destructive
  case .editingCredentials(.both, .left),
       .editingCredentials(.both, .none):
    return .normal
  default: return .disabled
  }
}

func errorMessage(from s: SignInState) -> String {
  switch s {
  case let .editingCredentials(_, .left(.both(_, e))),
       let .editingCredentials(_, .left(.that(e))):
    return e.rawValue.rawValue
  default: return ""
  }
}

func fieldInFocus(from s: SignInState) -> SignInScreen.State.Focus {
  switch s {
  case .editingCredentials(_, .left(.this(.email))),
       .editingCredentials(_, .left(.both(.email, _))):
    return .email
  case .editingCredentials(_, .left(.this(.password))),
       .editingCredentials(_, .left(.both(.password, _))):
    return .password
  default: return .none
  }
}

func signingIn(from s: SignInState) -> Bool {
  switch s {
  case .signingIn: return true
  default: return false
  }
}

func visitHeaders(from vs: [Visit]) -> ([VisitHeader], [VisitHeader], [VisitHeader], [VisitHeader]) {
  var pending: [(Date, VisitHeader)] = []
  var visited: [(Date, VisitHeader)] = []
  var completed: [(Date, VisitHeader)] = []
  var canceled: [(Date, VisitHeader)] = []
  
  for v in vs {
    let t = visitTitle(from: v)
    switch v {
    case let .left(m):
      let h = VisitHeader(id: m.id.rawValue.rawValue, title: t)
      switch m.geotagSent {
      case .checkedIn:  visited.append((m.createdAt, h))
      case .checkedOut: completed.append((m.createdAt, h))
      case .notSent: pending.append((m.createdAt, h))
      }
    case let .right(a):
      let h = VisitHeader(id: a.id.rawValue.rawValue, title: t)
      switch a.geotagSent {
      case .notSent, .pickedUp: pending.append((a.createdAt, h))
      case .entered, .visited:  visited.append((a.createdAt, h))
      case .checkedOut:         completed.append((a.createdAt, h))
      case .cancelled:          canceled.append((a.createdAt, h))
      }
    }
  }
  return (
    pending.sorted(by: sortHeaders).map(\.1),
    visited.sorted(by: sortHeaders).map(\.1),
    completed.sorted(by: sortHeaders).map(\.1),
    canceled.sorted(by: sortHeaders).map(\.1)
  )
}

func sortHeaders(_ left: (date: Date, visit: VisitHeader), _ right: (date: Date, visit: VisitHeader)) -> Bool {
  left.date > right.date
}

func visitScreen(from v: Visit, pk: String, dID: String) -> VisitScreen.State {
  let visitNote: String
  let visitType: VisitScreen.State.VisitType
  let noteFieldFocused: Bool
  switch v {
  case let .left(m):
    visitNote = m.visitNote?.rawValue.rawValue ?? ""
    noteFieldFocused = m.noteFieldFocused
    switch m.geotagSent {
    case .checkedIn:
      visitType = .manualVisit(status: .checkedIn)
    case let .checkedOut(d):
      visitType = .manualVisit(status: .checkedOut(DateFormatter.stringDate(d)))
    case .notSent:
      visitType = .manualVisit(status: .notSent)
    }
  case let .right(a):
    visitNote = a.visitNote?.rawValue.rawValue ?? ""
    noteFieldFocused = a.noteFieldFocused
    let status: VisitScreen.State.VisitType.AssignedVisitStatus
    switch a.geotagSent {
    case .notSent:
      status = .notSent
    case .pickedUp:
      status = .pickedUp
    case let .entered(entry):
      status = .entered(DateFormatter.stringDate(entry))
    case let .visited(entry, exit):
      status = .visited("\(DateFormatter.stringDate(entry)) — \(DateFormatter.stringDate(exit))")
    case let .checkedOut(visited, checkedOutDate):
      status = .checkedOut(visited: visited.map(visitedString(_:)), completed: DateFormatter.stringDate(checkedOutDate))
    case let .cancelled(visited, cancelledDate):
      status = .canceled(visited: visited.map(visitedString(_:)), canceled: DateFormatter.stringDate(cancelledDate))
    }
    visitType = .assignedVisit(coordinate: a.location, address: assignedVisitFullAddress(from: a), metadata: assignedVisitMetadata(from: a), status: status)
  }
  return .init(
    title: visitTitle(from: v),
    visitNote: visitNote,
    noteFieldFocused: noteFieldFocused,
    visitType: visitType,
    deviceID: dID,
    publishableKey: pk
  )
}

func visitedString(_ visited: AssignedVisit.Geotag.Visited) -> String {
  switch visited {
  case let .entered(entry): return DateFormatter.stringDate(entry)
  case let .visited(entry, exit): return "\(DateFormatter.stringDate(entry)) — \(DateFormatter.stringDate(exit))"
  }
}

func visitTitle(from v: Visit) -> String {
  switch v {
  case let .left(m):
    switch m.geotagSent {
    case .checkedIn: return "Visit \(DateFormatter.stringDate(m.createdAt))"
    case let .checkedOut(d): return "Visit \(DateFormatter.stringDate(m.createdAt)) — \(DateFormatter.stringDate(d))"
    case .notSent:
      return "New Visit"
    }
  case let .right(a):
    switch a.address {
    case .none: return "Visit @ \(DateFormatter.stringDate(a.createdAt))"
    case let .some(.both(s, _)),
         let .some(.this(s)): return s.rawValue.rawValue
    case let .some(.that(f)): return f.rawValue.rawValue
    }
  }
}

func assignedVisitFullAddress(from a: AssignedVisit) -> String {
  switch a.address {
  case .none: return ""
  case let .some(.both(_, f)): return f.rawValue.rawValue
  case let .some(.this(s)): return s.rawValue.rawValue
  case let .some(.that(f)): return f.rawValue.rawValue
  }
}

func assignedVisitMetadata(from a: AssignedVisit) -> [VisitScreen.State.Metadata] {
  a.metadata
    .map(identity)
    .sorted(by: \.key)
    .map { (name: AssignedVisit.Name, contents: AssignedVisit.Contents) in
    VisitScreen.State.Metadata(key: "\(name)", value: "\(contents)")
  }
}

extension Sequence {
  func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
    return sorted { a, b in
      return a[keyPath: keyPath] < b[keyPath: keyPath]
    }
  }
}

extension DateFormatter {
  static func stringDate(_ date: Date) -> String {
    let dateFormat = DateFormatter()
    dateFormat.locale = Locale(identifier: "en_US_POSIX")
    dateFormat.dateFormat = "h:mm a"
    return dateFormat.string(from: date)
  }
}

func mapVisits(from visits: Set<AssignedVisit>) -> [MapVisit] {
  visits.map { MapVisit(id: $0.id.rawValue.rawValue, coordinate: $0.location, status: mapVisitStatus(from: $0.geotagSent)) }
}

func mapVisitStatus(from geotagSent: AssignedVisit.Geotag) -> MapVisit.Status {
  switch geotagSent {
  case .notSent, .pickedUp: return .pending
  case .entered, .visited:  return .visited
  case .checkedOut:         return .completed
  case .cancelled:          return .canceled
  }
}
