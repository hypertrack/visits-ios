import AppLogic
import AppScreen
import BlockerScreen
import ComposableArchitecture
import LoadingScreen
import MapScreen
import OrderScreen
import OrdersListScreen
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
  let alert: Alert?
  switch appState {
  case let .operational(o):
    alert = o.alert
    
    switch o.flow {
    case .firstRun: screen = .loading
    case let .signIn(s):
      screen = .signIn(s)
    case let .main(m):
      
      switch o.sdk.status {
      case .locked: screen = .blocker(.waiting)
      case let .unlocked(deID, us):
        
        switch (us, o.pushStatus, o.locationAlways) {
        case (.outage(.blockedFromRunning), _, _):
          screen = .blocker(.deleted(deID.string))
        case (.outage(.invalidPublishableKey), _, _):
          screen = .blocker(.invalidPublishableKey(deID.string))
        case (.outage(.locationServicesDisabled), _, _):
          screen = .blocker(.locationDisabled)
        case (.outage(.permissionLocationDenied), _, _):
          screen = .blocker(.locationDenied)
        case (.outage(.permissionLocationRestricted), _, _):
          screen = .blocker(.locationRestricted)
        case (.outage(.permissionLocationNotDetermined), _, _):
          screen = .blocker(.locationNotDetermined)
        case (.outage(.permissionLocationProvisional), _, _):
          screen = .blocker(.locationProvisional)
        case (.outage(.permissionLocationReducedAccuracy), _, _):
          screen = .blocker(.locationReduced)
        case (_, _, .notRequested):
          screen = .blocker(.locationWhenInUseFirstRequest)
        case (.outage(.permissionLocationInsufficientForBackground), _, .requestedAfterWhenInUse):
          screen = .blocker(.locationWhenInUse)
        case (_, .dialogSplash(.notShown), _),
             (_, .dialogSplash(.waitingForUserAction), _):
          screen = .blocker(.pushNotShown)
        // case (.stopped, _, _):
        //   screen = .blocker(.stopped)
        case (.running, .dialogSplash(.shown), .requestedAfterWhenInUse),
          (.stopped, .dialogSplash(.shown), .requestedAfterWhenInUse),
          (.outage(.locationMocked), .dialogSplash(.shown), .requestedAfterWhenInUse),
          (.outage(.locationSignalLost), .dialogSplash(.shown), .requestedAfterWhenInUse):
          if let flow = m.addPlace {
            screen = .addPlace(flow, m.places?.places ?? [])
            break
          }
         
          screen = .main(
            MainBlockState(mapState: m.map,
                           placesSummary: m.places,
                           selectedPlace: m.selectedPlace,
                           placesPresentation: m.placesPresentation,
                           requests: m.requests,
                           history: m.history,
                           trip: m.trip,
                           selectedOrderId: m.selectedOrderId,
                           profile: m.profile,
                           integrationStatus: m.integrationStatus,
                           deviceID: deID,
                           sdkStatus: o.sdk.status,
                           selectedTeamWorker: m.selectedTeamWorker,
                           selectedVisit: m.selectedVisit,
                           tabSelection: m.tab,
                           team: m.team,
                           version: o.version,
                           visits: m.visits,
                           visitsDateFrom: m.visitsDateFrom,
                           visitsDateTo: m.visitsDateTo,
                           workerHandle: m.workerHandle,
                           publishableKey: m.publishableKey
                           )
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
    errorAlert: alert?.errorAlert,
    errorReportingAlert: alert?.sendErrorReport
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
  case .blocker(.locationProvisionalButtonTapped): return .openSettings
  case .blocker(.pushNotShownButtonTapped): return .requestPushAuthorization
  case .orders(.clockInToggleTapped): return .clockInToggleTapped
  case .orders(.refreshButtonTapped): return .updateOrders
  case let .orders(.orderTapped(o)): return .selectOrder(o)
  case let .order(.cancelButtonTapped(oid)): return .cancelOrder(oid)
  case let .order(.checkOutButtonTapped(oid)): return .completeOrder(oid)
  case let .order(.copyTextPressed(t)): return .copyToPasteboard(t)
  case let .order(.mapTapped(c, a)), let .places(.mapTapped(c, a)): return .openInMaps(c, a)
  case .order(.noteEnterKeyboardButtonTapped): return .dismissFocus
  case let .order(.noteFieldChanged(oid, d)) where d.isEmpty: return .orderNoteChanged(oid, nil)
  case let .order(.noteFieldChanged(oid, d)): return .orderNoteChanged(oid, .init(stringLiteral: d))
  case let .order(.noteTapped(oid)): return .focusOrderNote(oid)
  case let .order(.tappedOutsideFocusedTextField(oid)): return .orderDismissFocus(oid)
  case .tab(.map): return .switchToMap
  case .tab(.orders): return .switchToOrders
  case .tab(.visits): return .switchToVisits
  case .tab(.profile): return .switchToProfile
  case .tab(.team): return .switchToTeam
  case .map(.clockInToggleTapped): return .clockInToggleTapped
  case .map(.regionDidChange): return .mapRegionDidChange
  case .map(.regionWillChange): return .mapRegionWillChange
  case let .map(.selectedOrder(o)): return .selectOrder(o.id)
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
  case let .addPlace(.selectedPlace(p)): return .selectPlace(p)
  case let .addPlace(.selectedIntegration(ie)): return .selectedIntegration(ie)
  case let .places(.copyToPasteboard(s)): return .copyToPasteboard(s)
  case let .places(.selectPlace(p)): return .selectPlace(p)
  case .addPlace(.liftedAddPlaceCoordinatePin): return .liftedAddPlaceCoordinatePin
  case .addPlace(.searchPlaceByAddress): return .searchPlaceByAddress
  case .addPlace(.cancelChoosingAddress): return .cancelChoosingAddress
  case .addPlace(.searchPlaceOnMap): return .searchPlaceOnMap
  case let .addPlace(.selectAddress(ls)): return .selectAddress(ls)
  case let .addPlace(.updateAddressSearch(st)): return .updateAddressSearch(st)
  case .addPlace(.cancelConfirmingLocation): return .cancelConfirmingLocation
  case let .addPlace(.confirmAddPlaceLocation(mp)): return .confirmAddPlaceLocation(mp)
  case let .addPlace(.addPlaceDescriptionUpdated(d)): return .addPlaceDescriptionUpdated(d)
  case .addPlace(.cancelEditingAddPlaceMetadata): return .cancelEditingAddPlaceMetadata
  case .addPlace(.chooseCompany): return .chooseCompany
  case .addPlace(.createPlaceTapped): return .createPlaceTapped
  case let .addPlace(.customAddressUpdated(a)): return .customAddressUpdated(a)
  case .addPlace(.decreaseAddPlaceRadius): return .decreaseAddPlaceRadius
  case .addPlace(.increaseAddPlaceRadius): return .increaseAddPlaceRadius
  case let .places(.changePlacesPresentation(pp)): return .changePlacesPresentation(pp)
  case let .order(.snoozeButtonTapped(oid)): return .snoozeOrder(oid)
  case let .order(.unsnoozeButtonTapped(oid)): return .unsnoozeOrder(oid)
  case let .visits(.loadVisits(from: from, to: to, wh)): return .updateVisits(from: from, to: to, wh)
  case let .visits(.selectVisit(v)): return .selectVisit(v)
  case let .visits(.copyToPasteboard(i)): return .copyToPasteboard(i)
  case let .team(.updateTeam(wh)): return .updateTeam(wh)
  case let .team(.selectTeamWorker(wh)): return .selectTeamWorker(wh)
  case let .team(.teamWorkerVisitsAction(a, _)):
      switch a {
          case let .copyToPasteboard(i):                return .copyToPasteboard(i)
          case let .selectVisit(v):                     return .teamWorkerVisitsAction(.selectVisit(v))
          case let .loadVisits(from: from, to: to, wh): return .updateVisits(from: from, to: to, wh)
      }
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
