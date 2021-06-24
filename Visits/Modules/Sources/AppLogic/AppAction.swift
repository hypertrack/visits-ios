import NonEmpty
import Types
import UIKit
import Utility


public enum AppAction: Equatable {
  // DeepLink
  case deepLinkOpened(URL)
  case deepLinkFirstRunWaitingComplete
  case applyFullDeepLink(PublishableKey, DriverID, SDKStatusUpdate)
  case applyPartialDeepLink(PublishableKey)
  // OS
  case copyToPasteboard(NonEmptyString)
  case osFinishedLaunching
  case shakeDetected
  case willEnterForeground
  // Sign In
  case cancelSignIn
  case emailChanged(Email?)
  case focusEmail
  case focusPassword
  case passwordChanged(Password?)
  case signIn
  case signedIn(Result<PublishableKey, APIError<CognitoError>>)
  // DriverID
  case driverIDChanged(DriverID?)
  case setDriverID
  // Map
  case mapRegionWillChange
  case mapRegionDidChange
  case mapEnableAutoZoom
  // Orders
  case selectOrder(String)
  case updateOrders
  // Order
  case cancelOrder
  case checkOutOrder
  case orderNoteChanged(NonEmptyString?)
  case deselectOrder
  case focusOrderNote
  case openAppleMaps
  case orderCancelFinished(Result<Terminal, APIError<Never>>)
  case orderCompleteFinished(Result<Terminal, APIError<Never>>)
  case ordersUpdated(Result<Set<Order>, APIError<Never>>)
  // Places
  case placesUpdated(Result<Set<Place>, APIError<Never>>)
  case updatePlaces
  // TabView
  case switchToOrders
  case switchToPlaces
  case switchToMap
  case switchToSummary
  case switchToProfile
  // History
  case historyUpdated(Result<History, APIError<Never>>)
  // Generic UI
  case dismissFocus
  // SDK
  case madeSDK(SDKStatusUpdate)
  case openSettings
  case requestAlwaysLocationPermissions
  case requestWhenInUseLocationPermissions
  case requestMotionPermissions
  case statusUpdated(SDKStatusUpdate)
  case startTracking
  case stopTracking
  // Push
  case receivedPushNotification
  case requestPushAuthorization
  case userHandledPushAuthorization
  // State
  case restoredState(StorageState?, AppVersion, StateRestorationError?)
  // Alert
  case errorAlert(ErrorAlertAction)
  case errorReportingAlert(ErrorReportingAlertAction)
  // Internal
  case generated(InternalAction)
}

// https://statecharts.dev/glossary/internal-event.html
public enum InternalAction: Equatable {
  case entered(EnteredAction)
  case changed(ChangedAction)
}

public enum EnteredAction: Equatable {
  case stateRestored
  case started
  case operational
  case mainUnlocked
  case firstRunReadyToStart
}

public enum ChangedAction: Equatable {
  case storage(StorageState)
}
