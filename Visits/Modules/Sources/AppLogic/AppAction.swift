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
  case openInMaps(Coordinate, Address)
  case reverseGeocoded(GeocodedResult)
  // Requests
  case tokenUpdated(Result<Token.Value, APIError<Never>>)
  case cancelAllRequests
  case refreshAllRequests
  case receivedCurrentLocation(Coordinate?)
  // Orders
  case selectOrder(Order.ID?)
  case updateOrders
  // Order
  case cancelSelectedOrder(Order.ID)
  case cancelOrder(Order)
  case completeSelectedOrder(Order.ID)
  case checkOutOrder(Order)
  case orderNoteChanged(Order.ID, NonEmptyString?)
  case focusOrderNote(Order.ID)
  case orderDismissFocus(Order.ID)
  case orderCancelFinished(Order, Result<Terminal, APIError<Token.Expired>>)
  case orderCompleteFinished(Order, Result<Terminal, APIError<Token.Expired>>)
  case tripUpdated(Result<Trip?, APIError<Token.Expired>>)
  // Places
  case selectPlace(Place?)
  case placesUpdated(Result<PlacesSummary, APIError<Token.Expired>>)
  case updatePlaces
  case createPlace(PlaceCenter, PlaceRadius, IntegrationEntity, CustomAddress?, PlaceDescription?)
  case placeCreatedWithSuccess(Place)
  case placeCreatedWithFailure(APIError<Token.Expired>)
  case changePlacesPresentation(PlacesPresentation)
  // Adding Place
  case addPlace
  //   Choosing Coordinate
  case cancelAddPlace
  case confirmAddPlaceCoordinate
  case liftedAddPlaceCoordinatePin
  case searchPlaceByAddress
  case updatedAddPlaceCoordinate(Coordinate)
  //   Choosing Address
  case cancelChoosingAddress
  case localSearchCompletionResultsUpdated([LocalSearchCompletion])
  case localSearchUpdatedWithResult(MapPlace)
  case localSearchUpdatedWithResults(MapPlace, NonEmptyArray<MapPlace>)
  case localSearchUpdatedWithEmptyResult
  case localSearchUpdatedWithError(LocalSearchResult.Error)
  case localSearchUpdatedWithFatalError
  case searchPlaceOnMap
  case selectAddress(LocalSearchCompletion)
  case updateAddressSearch(AddressSearch?)
  //   Confirming Location
  case cancelConfirmingLocation
  case confirmAddPlaceLocation(MapPlace)
  //   Editing Metadata
  case addPlaceDescriptionUpdated(PlaceDescription?)
  case cancelEditingAddPlaceMetadata
  case chooseCompany
  case createPlaceTapped
  case customAddressUpdated(CustomAddress?)
  case decreaseAddPlaceRadius
  case increaseAddPlaceRadius
  //   Choosing Integration
  case cancelChoosingCompany
  case searchForIntegrations
  case selectedIntegration(IntegrationEntity)
  case updateIntegrationsSearch(IntegrationSearch)
  // Integration Entities
  case updateIntegrations(IntegrationSearch)
  case integrationEntitiesUpdatedWithSuccess([IntegrationEntity])
  case integrationEntitiesUpdatedWithFailure(APIError<Token.Expired>)
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
  case errorReportingAlert(SendErrorReportAction)
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
