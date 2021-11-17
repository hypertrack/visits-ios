import AppArchitecture
import ComposableArchitecture
import NonEmpty
import Types
import Utility


// MARK: - State

public struct AddPlaceState: Equatable {
  public var adding: AddPlace?
  public var history: History
  
  public init(adding: AddPlace? = nil, history: History) { self.adding = adding; self.history = history }
}

// MARK: - Action

public enum AddPlaceAction: Equatable {
  case addPlace
  case addPlaceDescriptionUpdated(PlaceDescription?)
  case cancelAddPlace
  case cancelChoosingAddress
  case cancelChoosingCompany
  case cancelConfirmingLocation
  case cancelEditingAddPlaceMetadata
  case chooseCompany
  case confirmAddPlaceCoordinate
  case confirmAddPlaceLocation(MapPlace)
  case createPlace(PlaceCenter, PlaceRadius, IntegrationEntity, CustomAddress?, PlaceDescription?)
  case createPlaceTapped
  case customAddressUpdated(CustomAddress?)
  case decreaseAddPlaceRadius
  case increaseAddPlaceRadius
  case integrationEntitiesUpdatedWithSuccess([IntegrationEntity])
  case integrationEntitiesUpdatedWithFailure(APIError<Token.Expired>)
  case liftedAddPlaceCoordinatePin
  case localSearchCompletionResultsUpdated([LocalSearchCompletion])
  case localSearchUpdatedWithResult(MapPlace)
  case localSearchUpdatedWithResults(MapPlace, NonEmptyArray<MapPlace>)
  case localSearchUpdatedWithEmptyResult
  case localSearchUpdatedWithError(LocalSearchResult.Error)
  case localSearchUpdatedWithFatalError
  case placeCreatedWithSuccess(Place)
  case placeCreatedWithFailure(APIError<Token.Expired>)
  case reverseGeocoded(GeocodedResult)
  case searchForIntegrations
  case searchPlaceByAddress
  case searchPlaceOnMap
  case selectAddress(LocalSearchCompletion)
  case selectPlace(Place)
  case selectedIntegration(IntegrationEntity)
  case updateAddressSearch(AddressSearch?)
  case updateIntegrations(IntegrationSearch)
  case updateIntegrationsSearch(IntegrationSearch)
  case updatedAddPlaceCoordinate(Coordinate)
}

// MARK: - Environment

public struct AddPlaceEnvironment {
  public var autocompleteLocalSearch: (AddressSearch?, Coordinate) -> Effect<Never, Never>
  public var capture: (CaptureMessage) -> Effect<Never, Never>
  public var localSearch: (LocalSearchCompletion, Coordinate) -> Effect<LocalSearchResult, Never>
  public var reverseGeocode: (Coordinate) -> Effect<GeocodedResult, Never>
  public var subscribeToLocalSearchCompletionResults: () -> Effect<[LocalSearchCompletion], Never>
  
  public init(
    autocompleteLocalSearch: @escaping (AddressSearch?, Coordinate) -> Effect<Never, Never>,
    capture: @escaping (CaptureMessage) -> Effect<Never, Never>,
    localSearch: @escaping (LocalSearchCompletion, Coordinate) -> Effect<LocalSearchResult, Never>,
    reverseGeocode: @escaping (Coordinate) -> Effect<GeocodedResult, Never>,
    subscribeToLocalSearchCompletionResults: @escaping () -> Effect<[LocalSearchCompletion], Never>
  ) {
    self.autocompleteLocalSearch = autocompleteLocalSearch
    self.capture = capture
    self.localSearch = localSearch
    self.reverseGeocode = reverseGeocode
    self.subscribeToLocalSearchCompletionResults = subscribeToLocalSearchCompletionResults
  }
}

// MARK: - Reducer

public let addPlaceReducer: Reducer<
  AddPlaceState,
  AddPlaceAction,
  SystemEnvironment<AddPlaceEnvironment>
> = .combine(
  choosingCoordinateP,
  destinationPickerPlaceP,
  editingMetadataP,
  flowSwitchingP
)




let addPlaceDestinationoPrism = Prism<AddPlaceAction, DestinationPickerAction>(
  extract: { a in
    switch a {
    //adderess
    case     .cancelConfirmingLocation:                 return .addressAction(.cancelConfirmingLocation)
    case let .localSearchCompletionResultsUpdated(lss): return .addressAction(.localSearchCompletionResultsUpdated(lss))
    case let .localSearchUpdatedWithResult(mp):         return .addressAction(.localSearchUpdatedWithResult(mp))
    case let .localSearchUpdatedWithResults(mp, mps):   return .addressAction(.localSearchUpdatedWithResults(mp, mps))
    case     .localSearchUpdatedWithEmptyResult:        return .addressAction(.localSearchUpdatedWithEmptyResult)
    case let .localSearchUpdatedWithError(e):           return .addressAction(.localSearchUpdatedWithError(e))
    case     .localSearchUpdatedWithFatalError:         return .addressAction(.localSearchUpdatedWithFatalError)
    case let .selectAddress(ls):                        return .addressAction(.selectAddress(ls))
    case let .updateAddressSearch(st):                  return .addressAction(.updateAddressSearch(st))
    //coordinate
    case     .liftedAddPlaceCoordinatePin:              return .liftedAddPlaceCoordinatePin
    case let .reverseGeocoded(gr):                      return .reverseGeocoded(gr)
    case let .updatedAddPlaceCoordinate(c):             return .updatedAddPlaceCoordinate(c)
    default                                             return nil
    }
},
  embed: { a in
    return
  }
)
