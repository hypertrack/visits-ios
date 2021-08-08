import AppLogic
import AppScreen
import BlockerScreen
import ComposableArchitecture
import LoadingScreen
import MapScreen
import OrderScreen
import OrdersScreen
import Utility
import SignInScreen
import Types


// MARK: - Life Cycle

public enum LifeCycleAction {
  case finishedLaunching
  case deepLinkOpened(URL)
  case receivedPushNotification
  case shakeDetected
  case appVisibilityChanged(AppVisibility)
}

public extension ViewStore where State == Terminal, Action == LifeCycleAction {
  static func lifeCycleViewStore(from store: Store<AppState, AppAction>) -> ViewStore {
    ViewStore(
      store.scope(
        state: { _ in unit },
        action: { a in
          switch a {
          case let .appVisibilityChanged(v):  return .appVisibilityChanged(v)
          case let .deepLinkOpened(u):        return .deepLinkOpened(u)
          case     .finishedLaunching:        return .osFinishedLaunching
          case     .receivedPushNotification: return .receivedPushNotification
          case     .shakeDetected:            return .shakeDetected
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
  let screen: AppScreen.Screen
  let alert: Either<AlertState<ErrorAlertAction>, AlertState<ErrorReportingAlertAction>>?
  switch appState {
  case let .operational(o):
    alert = o.alert
    
    switch o.flow {
    case .firstRun: screen = .loading
    case let .signIn(s):
      screen = .signIn(s)
    case let .main(m):
      
      switch o.sdk.status {
      case .locked: screen = .blocker(.noMotionServices)
      case let .unlocked(deID, us):
        
        switch (us, o.sdk.permissions.locationAccuracy, o.sdk.permissions.locationPermissions, o.sdk.permissions.motionPermissions, o.pushStatus) {
        case (_, _, .disabled, _, _):                            screen = .blocker(.locationDisabled)
        case (_, _, .denied, _, _):                              screen = .blocker(.locationDenied)
        case (_, _, .restricted, _, _):                          screen = .blocker(.locationRestricted)
        case (_, _, .notDetermined, _, _):                       screen = .blocker(.locationNotDetermined)
        case (_, _, .authorizedWhenInUse, _, _):
          if o.locationAlways == .notRequested {
            screen = .blocker(.locationWhenInUseFirstRequest)
          } else {
            screen = .blocker(.locationWhenInUse)
          }
        case (_, .reduced, _, _, _):                             screen = .blocker(.locationReduced)
        case (_, _, _, .disabled, _):                            screen = .blocker(.motionDisabled)
        case (_, _, _, .denied, _):                              screen = .blocker(.motionDenied)
        case (_, _, _, .notDetermined, _):                       screen = .blocker(.motionNotDetermined)
        case (_, _, _, _, .dialogSplash(.notShown)),
             (_, _, _, _, .dialogSplash(.waitingForUserAction)): screen = .blocker(.pushNotShown)
        case (.deleted, _, _, _, _):                             screen = .blocker(.deleted(deID.string))
        case (.invalidPublishableKey, _, _, _, _):               screen = .blocker(.invalidPublishableKey(deID.string))
        case (.stopped, _, _, _, _):                             screen = .blocker(.stopped)
        case (.running, .full, .authorizedAlways, .authorized, .dialogSplash(.shown)):
          if let flow = m.addPlace {
            screen = .addPlace(flow)
            break
          }
          
          let ord: OrderOrOrders
          switch m.selectedOrder {
          case     .none:        ord = .orders(m.orders)
          case let .some(order): ord = .order(order)
          }
          
          screen = .main(
            m.map,
            ord,
            m.places,
            m.requests,
            m.history,
            m.selectedOrder.map { Set.insert($0)(m.orders) } ?? m.orders,
            m.profile,
            m.integrationStatus,
            deID,
            m.tab,
            o.version
          )
        }
      }
    }
  default:
    alert = nil
    screen = .loading
  }
  
  return .init(
    screen: screen,
    errorAlert: alert >>- eitherLeft,
    errorReportingAlert: alert >>- eitherRight
  )
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
  case .blocker(.deletedButtonTapped): return .startTracking
  case .blocker(.invalidPublishableKeyButtonTapped): return .startTracking
  case .blocker(.stoppedButtonTapped): return .startTracking
  case .blocker(.locationWhenInUseButtonTapped): return .openSettings
  case .blocker(.locationWhenInUseFirstRequestButtonTapped): return .requestAlwaysLocationPermissions
  case .blocker(.locationDeniedButtonTapped): return .openSettings
  case .blocker(.locationDisabledButtonTapped): return .openSettings
  case .blocker(.locationNotDeterminedButtonTapped): return .requestWhenInUseLocationPermissions
  case .blocker(.locationRestrictedButtonTapped): return .openSettings
  case .blocker(.locationReducedButtonTapped): return .openSettings
  case .blocker(.motionDeniedButtonTapped): return .openSettings
  case .blocker(.motionDisabledButtonTapped): return .openSettings
  case .blocker(.motionNotDeterminedButtonTapped): return .requestMotionPermissions
  case .blocker(.pushNotShownButtonTapped): return .requestPushAuthorization
  case .orders(.clockOutButtonTapped): return .stopTracking
  case .orders(.refreshButtonTapped): return .updateOrders
  case let .orders(.orderTapped(o)): return .selectOrder(o)
  case .order(.backButtonTapped): return .deselectOrder
  case .order(.cancelButtonTapped): return .cancelSelectedOrder
  case .order(.checkOutButtonTapped): return .completeSelectedOrder
  case let .order(.copyTextPressed(t)): return .copyToPasteboard(t)
  case .order(.mapTapped): return .openAppleMaps
  case .order(.noteEnterKeyboardButtonTapped): return .dismissFocus
  case let .order(.noteFieldChanged(d)) where d.isEmpty: return .orderNoteChanged(nil)
  case let .order(.noteFieldChanged(d)): return .orderNoteChanged(.init(stringLiteral: d))
  case .order(.noteTapped): return .focusOrderNote
  case .order(.tappedOutsideFocusedTextField): return .dismissFocus
  case .tab(.map): return .switchToMap
  case .tab(.orders): return .switchToOrders
  case .tab(.summary): return .switchToSummary
  case .tab(.profile): return .switchToProfile
  case .map(.regionDidChange): return .mapRegionDidChange
  case .map(.regionWillChange): return .mapRegionWillChange
  case let .map(.selectedOrder(o)): return .selectOrder(o)
  case let .map(.selectedPlace(p)): return .selectPlace(p)
  case .map(.enableAutoZoom): return .mapEnableAutoZoom
  case .tab(.places): return .switchToPlaces
  case .places(.refresh): return .updatePlaces
  case .places(.addPlace): return .addPlace
  case .addPlace(.cancelAddPlace): return .cancelAddPlace
  case .addPlace(.confirmAddPlaceCoordinate): return .confirmAddPlaceCoordinate
  case let .addPlace(.updatedAddPlaceCoordinate(c)): return .updatedAddPlaceCoordinate(c)
  case let .errorAlert(ea):
    return .errorAlert(ea)
  case let .errorReportingAlert(era):
    return .errorReportingAlert(era)
  case let .profile(.copyTextPressed(t)): return .copyToPasteboard(t)
  case .addPlace(.cancelChoosingCompany): return .cancelChoosingCompany
  case let .addPlace(.updateIntegrationsSearch(s)): return .updateIntegrationsSearch(s)
  case .addPlace(.searchForIntegrations): return .searchForIntegrations
  case let .addPlace(.selectedIntegration(ie)): return .selectedIntegration(ie)
  case let .places(.copyToPasteboard(s)): return .copyToPasteboard(s)
  }
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
