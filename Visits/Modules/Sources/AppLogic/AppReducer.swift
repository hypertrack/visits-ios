import AppArchitecture
import ComposableArchitecture
import Utility
import Types


public let appReducer: Reducer<AppState, AppAction, SystemEnvironment<AppEnvironment>> = Reducer.combine(
  sdkLaunchingP,
  stateRestorationP,
  appVisibilityStartupP,
  appStartupP,
  sdkStatusUpdateP,
  sdkInitializationP,
  deepLinkP,
  errorAlertP,
  signInP,
  blockerP,
  mapP,
  tripP,
  placesP,
  addPlaceP,
  profileP,
  historyP,
  integrationP,
  requestP,
  appVisibilityP,
  tabP,
  autoSavingP,
  trackingP,
  firstRunP,
  manualReportP,
  visitsP,
  Reducer { _, action, environment in
    guard case let .copyToPasteboard(s) = action else { return .none }
    
    return .merge(
      environment.hapticFeedback.notifySuccess().fireAndForget(),
      environment.pasteboard.copyToPasteboard(s).fireAndForget()
    )
  }
)
.onExit(toSignInState, send: constant(_cancelSignInEffects()))
.onEntry(toStateRestored, send: constant(Effect(value: .generated(.entered(.stateRestored)))))
.onEntry(mainUnlocked, send: constant(Effect(value: .generated(.entered(.mainUnlocked)))))
.onEntry(appStartedState, send: constant(Effect(value: .generated(.entered(.started)))))
.onEntry(operationalStatePrism.extract, send: constant(Effect(value: .generated(.entered(.operational)))))
.onEntry(firstRunReadyState, send: constant(Effect(value: .generated(.entered(.firstRunReadyToStart)))))
.onChange(toStorageState, send: ChangedAction.storage >>> InternalAction.changed >>> AppAction.generated >>> Effect.init(value:))
.reportErrors()

let operationalStatePrism: Prism<AppState, OperationalState> = /AppState.operational
