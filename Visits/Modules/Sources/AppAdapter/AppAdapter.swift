import AppLogic
import AppScreen
import BlockerScreen
import ComposableArchitecture
import DriverIDScreen
import LoadingScreen
import MapScreen
import OrderScreen
import OrdersScreen
import Prelude
import SignInScreen
import SignUpFormScreen
import SignUpQuestionsScreen
import SignUpVerificationScreen
import Types



// MARK: - Life Cycle

public enum LifeCycleAction {
  case finishedLaunching
  case deepLinkOpened(NSUserActivity)
  case receivedPushNotification
  case shakeDetected
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
          case .shakeDetected:            return .shakeDetected
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
  let screen: AppScreen.Screen
  let alert: Either<AlertState<ErrorAlertAction>, AlertState<ErrorReportingAlertAction>>?
  switch appState {
  case let .operational(o):
    alert = o.alert
    
    switch o.flow {
    case .firstRun: screen = .loading
    case let .signUp(.form(form)):
      screen = .signUpForm(form)
    case let .signUp(.questions(questions)):
      screen = .signUpQuestions(questions.status)
    case let .signUp(.verification(verification)):
      screen = .signUpVerification(verification.status)
    case let .signIn(s):
      screen = .signIn(s)
    case let .driverID(driverID):
      screen = .driverID(driverID.status)
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
          let ord: OrderOrOrders
          switch m.selectedOrder {
          case     .none:        ord = .orders(m.orders)
          case let .some(order): ord = .order(order)
          }
          
          screen = .main(ord, m.places, m.refreshing, m.history, mapOrders(from: m.orders), m.driverID, deID, m.tab)
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
  case .signUpForm(.nameTapped): return .focusBusinessName
  case let .signUpForm(.nameChanged(n)) where n.isEmpty: return .businessNameChanged(nil)
  case let .signUpForm(.nameChanged(n)): return .businessNameChanged(.init(stringLiteral: n))
  case .signUpForm(.nameEnterKeyboardButtonTapped): return .focusEmail
  case .signUpForm(.emailTapped): return .focusEmail
  case let .signUpForm(.emailChanged(e)) where e.isEmpty: return .emailChanged(nil)
  case let .signUpForm(.emailChanged(e)): return .emailChanged(.init(stringLiteral: e))
  case .signUpForm(.emailEnterKeyboardButtonTapped): return .focusPassword
  case .signUpForm(.passwordTapped): return .focusPassword
  case let .signUpForm(.passwordChanged(p)) where p.isEmpty: return .passwordChanged(nil)
  case let .signUpForm(.passwordChanged(p)): return .passwordChanged(.init(stringLiteral: p))
  case .signUpForm(.passwordEnterKeyboardButtonTapped): return .completeSignUpForm
  case .signUpForm(.nextButtonTapped): return .completeSignUpForm
  case .signUpForm(.signInTapped): return .goToSignIn
  case .signUpForm(.tappedOutsideFocus): return .dismissFocus
  case let .signUpQuestions(.businessManagesChanged(bm)): return .businessManagesChanged(bm)
  case let .signUpQuestions(.managesForChanged(mf)): return .managesForChanged(mf)
  case .signUpQuestions(.businessManagesTapped): return .businessManagesSelected
  case .signUpQuestions(.managesForTapped): return .managesForSelected
  case .signUpQuestions(.deselectQuestions): return .dismissFocus
  case .signUpQuestions(.backButtonTapped): return .goToSignUp
  case .signUpQuestions(.acceptButtonTapped): return .signUp
  case .signUpQuestions(.cancelSignUpTapped): return .cancelSignUp
  case let .signUpVerification(.firstFieldChanged(s)): return .firstVerificationFieldChanged(s)
  case let .signUpVerification(.secondFieldChanged(s)): return .secondVerificationFieldChanged(s)
  case let .signUpVerification(.thirdFieldChanged(s)): return .thirdVerificationFieldChanged(s)
  case let  .signUpVerification(.fourthFieldChanged(s)): return .fourthVerificationFieldChanged(s)
  case let .signUpVerification(.fifthFieldChanged(s)): return .fifthVerificationFieldChanged(s)
  case let .signUpVerification(.sixthFieldChanged(s)): return .sixthVerificationFieldChanged(s)
  case .signUpVerification(.fieldsTapped): return .focusVerification
  case .signUpVerification(.tappedOutsideFocus): return .dismissFocus
  case .signUpVerification(.resendButtonTapped): return .resendVerificationCode
  case .signUpVerification(.signInTapped): return .goToSignIn
  case .signUpVerification(.backspacePressed): return .deleteVerificationDigit
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
  case .signIn(.signUpTapped): return .goToSignUp
  case .driverID(.buttonTapped): return .setDriverID
  case let .driverID(.driverIDChanged(d)) where d.isEmpty: return .driverIDChanged(nil)
  case let .driverID(.driverIDChanged(d)): return .driverIDChanged(.init(stringLiteral: d))
  case .driverID(.nextEnterKeyboardButtonTapped): return .setDriverID
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
  case let .orders(.orderTapped(id)): return .selectOrder(id)
  case .order(.backButtonTapped): return .deselectOrder
  case .order(.cancelButtonTapped): return .cancelOrder
  case .order(.checkOutButtonTapped): return .checkOutOrder
  case let .order(.copyTextPressed(t)): return .copyToPasteboard(t)
  case .order(.mapTapped): return .openAppleMaps
  case .order(.noteEnterKeyboardButtonTapped): return .dismissFocus
  case let .order(.noteFieldChanged(d)) where d.isEmpty: return .orderNoteChanged(nil)
  case let .order(.noteFieldChanged(d)): return .orderNoteChanged(.init(stringLiteral: d))
  case .order(.noteTapped): return .focusOrderNote
  case .order(.pickedUpButtonTapped): return .pickUpOrder
  case .order(.tappedOutsideFocusedTextField): return .dismissFocus
  case .tab(.map): return .switchToMap
  case .tab(.orders): return .switchToOrders
  case .tab(.summary): return .switchToSummary
  case .tab(.profile): return .switchToProfile
  case let .map(id): return .selectOrder(id)
  case .tab(.places): return .switchToPlaces
  case .places(.refresh): return .updatePlaces
  case let .errorAlert(ea):
    return .errorAlert(ea)
  case let .errorReportingAlert(era):
    return .errorReportingAlert(era)
  case let .profile(.copyTextPressed(t)): return .copyToPasteboard(t)
  }
}

func mapOrders(from orders: Set<Order>) -> [MapOrder] {
  orders.map { MapOrder(id: $0.id.string, coordinate: $0.location, status: mapVisitStatus(from: $0.geotagSent)) }
}

func mapVisitStatus(from geotagSent: Order.Geotag) -> MapOrder.Status {
  switch geotagSent {
  case .notSent, .pickedUp: return .pending
  case .entered, .visited:  return .visited
  case .checkedOut:         return .completed
  case .cancelled:          return .canceled
  }
}
