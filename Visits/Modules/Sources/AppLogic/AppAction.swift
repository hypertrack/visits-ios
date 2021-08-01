import NonEmpty
import Types
import UIKit
import Utility


public enum AppAction: Equatable {
  // DeepLink
  case deepLinkOpened(URL)
  case deepLinkFirstRunWaitingComplete
  case deepLinkFailed(NonEmptyArray<NonEmptyString>)
  case applyFullDeepLink(DeepLink, SDKStatusUpdate)
  // OS
  case copyToPasteboard(NonEmptyString)
  case osFinishedLaunching
  case shakeDetected
  case appVisibilityChanged(AppVisibility)
  // Sign In
  case cancelSignIn
  case emailChanged(Email?)
  case focusEmail
  case focusPassword
  case passwordChanged(Password?)
  case signIn
  case signedIn(Result<PublishableKey, APIError<CognitoError>>)
  // Map
  case mapRegionWillChange
  case mapRegionDidChange
  case mapEnableAutoZoom
  // Token
  case tokenUpdated(Result<Token.Value, APIError<Never>>)
  // Orders
  case selectOrder(Order)
  case updateOrders
  // Order
  case cancelSelectedOrder
  case cancelOrder(Order)
  case completeSelectedOrder
  case checkOutOrder(Order)
  case orderNoteChanged(NonEmptyString?)
  case deselectOrder
  case focusOrderNote
  case openAppleMaps
  case orderCancelFinished(Order, Result<Terminal, APIError<Token.Expired>>)
  case orderCompleteFinished(Order, Result<Terminal, APIError<Token.Expired>>)
  case ordersUpdated(Result<Set<Order>, APIError<Token.Expired>>)
  // Places
  case placesUpdated(Result<Set<Place>, APIError<Token.Expired>>)
  case updatePlaces
  // Adding Place
  case addPlace
  case cancelAddPlace
  case updatedAddPlaceCoordinate(Coordinate)
  // Integration Entities
  case integrationEntitiesUpdated(Result<[IntegrationEntity], APIError<Token.Expired>>)
  // Profile
  case profileUpdated(Result<Profile, APIError<Token.Expired>>)
  // TabView
  case switchToOrders
  case switchToPlaces
  case switchToMap
  case switchToSummary
  case switchToProfile
  // History
  case historyUpdated(Result<History, APIError<Token.Expired>>)
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
