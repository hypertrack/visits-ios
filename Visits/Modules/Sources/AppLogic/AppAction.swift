import NonEmpty
import Types
import UIKit


public enum AppAction: Equatable {
  // DeepLink
  case deepLinkOpened(NSUserActivity)
  case deepLinkFirstRunWaitingComplete
  case applyFullDeepLink(PublishableKey, DriverID, SDKStatusUpdate)
  case applyPartialDeepLink(PublishableKey)
  // OS
  case copyToPasteboard(NonEmptyString)
  case osFinishedLaunching
  case shakeDetected
  case willEnterForeground
  // Sign Up
  //   Form
  case focusBusinessName
  case businessNameChanged(BusinessName?)
  case completeSignUpForm
  case goToSignIn
  //   Questions
  case businessManagesSelected
  case managesForSelected
  case businessManagesChanged(BusinessManages?)
  case managesForChanged(ManagesFor?)
  case signUp
  case cancelSignUp
  case signedUp(Result<SignUpSuccess, APIError<CognitoError>>)
  //   Verification
  case verificationExtractedFromPasteboard(VerificationCode)
  case firstVerificationFieldChanged(String)
  case secondVerificationFieldChanged(String)
  case thirdVerificationFieldChanged(String)
  case fourthVerificationFieldChanged(String)
  case fifthVerificationFieldChanged(String)
  case sixthVerificationFieldChanged(String)
  case deleteVerificationDigit
  case focusVerification
  case resendVerificationCode
  case verificationCodeSent
  case receivedPublishableKey(PublishableKey)
  case autoSignInFailed(APIError<CognitoError>)
  // Sign In
  case goToSignUp
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
  case pickUpOrder
  case reverseGeocoded([GeocodedResult])
  case ordersUpdated(Result<[APIOrderID: APIOrder], APIError<Never>>)
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
