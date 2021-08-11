import AppArchitecture
import ComposableArchitecture
import Types
import Utility


// MARK: - State

public struct AddPlaceState: Equatable {
  public var flow: AddPlaceFlow?
  public var history: History?
  
  public init(flow: AddPlaceFlow? = nil, history: History? = nil) { self.flow = flow; self.history = history }
}

// MARK: - Action

public enum AddPlaceAction: Equatable {
  case addPlace
  case cancelAddPlace
  case cancelChoosingAddress
  case cancelChoosingCompany
  case cancelConfirmingLocation
  case confirmAddPlaceCoordinate
  case confirmAddPlaceLocation(MapPlace)
  case createPlace(Coordinate, IntegrationEntity)
  case integrationEntitiesUpdated(Result<[IntegrationEntity], APIError<Token.Expired>>)
  case liftedAddPlaceCoordinatePin
  case localSearchCompletionResultsUpdated([LocalSearchCompletion])
  case localSearchUpdated(LocalSearchResult)
  case placeCreated(Result<Place, APIError<Token.Expired>>)
  case reverseGeocoded(GeocodedResult)
  case searchForIntegrations
  case searchPlaceByAddress
  case searchPlaceOnMap
  case selectAddress(LocalSearchCompletion)
  case selectPlace(Place)
  case selectedIntegration(IntegrationEntity)
  case updateAddressSearch(Street?)
  case updateIntegrations(IntegrationEntity.Search)
  case updateIntegrationsSearch(IntegrationEntity.Search)
  case updatedAddPlaceCoordinate(Coordinate)
}

// MARK: - Environment

public struct AddPlaceEnvironment {
  public var autocompleteLocalSearch: (Street?, Coordinate) -> Effect<Never, Never>
  public var capture: (CaptureMessage) -> Effect<Never, Never>
  public var localSearch: (LocalSearchCompletion, Coordinate) -> Effect<LocalSearchResult, Never>
  public var reverseGeocode: (Coordinate) -> Effect<GeocodedResult, Never>
  public var subscribeToLocalSearchCompletionResults: () -> Effect<[LocalSearchCompletion], Never>
  
  public init(
    autocompleteLocalSearch: @escaping (Street?, Coordinate) -> Effect<Never, Never>,
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

public let addPlaceReducer = Reducer<AddPlaceState, AddPlaceAction, SystemEnvironment<AddPlaceEnvironment>> { state, action, environment in
  let reverseGeocode = reverseGeocode(
    rge: environment.reverseGeocode,
    main: environment.mainQueue
  )
  let autocompleteLocalSearch = autocompleteLocalSearch(
    als: environment.autocompleteLocalSearch,
    main: environment.mainQueue
  )
  let localSearch = localSearch(
    ls: environment.localSearch,
    main: environment.mainQueue
  )
  
  switch action {
  case .addPlace:
    guard state.flow == nil
    else { return environment.capture("Can't add place when already adding place").fireAndForget() }
    
    guard let currentLocation = state.history?.coordinates.last else { return .none }
    
    state.flow = .choosingCoordinate(.init(coordinate: currentLocation), [])
    
    return .merge(
      reverseGeocode(currentLocation),
      Effect(value: .updateIntegrations(""))
    )
  case .cancelAddPlace:
    guard case .choosingCoordinate = state.flow
    else { return environment.capture("Trying to cancel adding place when not choosing coordinate").fireAndForget() }
    
    state.flow = nil
    
    return .none
  case .cancelChoosingAddress:
    guard case .choosingAddress = state.flow
    else { return environment.capture("Trying to cancel choosing address when not choosing address").fireAndForget() }
    
    state.flow = nil
    
    return .cancel(id: LocalSearchCompletionResultsSubscriptionID())
  case .cancelChoosingCompany:
    guard case let .choosingIntegration(c, a, _, _, ies) = state.flow
    else { return environment.capture("Trying to cancel choosing company when not choosing company").fireAndForget() }
    
    state.flow = .choosingCoordinate(.init(coordinate: c, address: a), ies)
    
    return .none
  case .cancelConfirmingLocation:
    guard case let .confirmingLocation(c, st, _, _, lss, ies) = state.flow
    else { return environment.capture("Trying to cancel confirming location when not confirming location").fireAndForget() }
    
    state.flow = .choosingAddress(c, st, nil, lss, ies)
    
    return .none
  case .confirmAddPlaceCoordinate:
    guard case let .choosingCoordinate(gr, ies) = state.flow
    else { return environment.capture("Trying to confirm a place coordinate when not on choosing coordinate screen").fireAndForget() }
    
    guard let gr = gr
    else { return environment.capture("Trying to confirm a place coordinate without a coordinate").fireAndForget() }
    
    state.flow = .choosingIntegration(gr.coordinate, gr.address, "", .notRefreshing, ies)
    
    return .none
  case let .confirmAddPlaceLocation(mp):
    guard case let .confirmingLocation(c, st, ls, mps, lss, ies) = state.flow
    else { return environment.capture("Trying to confirm a place location when not in place location confirmation screen").fireAndForget() }
    
    state.flow = .choosingIntegration(mp.location, mp.address, "", .notRefreshing, ies)
    
    return .none
  case .createPlace:
    return .none
  case let .integrationEntitiesUpdated(.success(ies)):
    guard let flow = state.flow else { return .none }
    
    state.flow = flow |> AddPlaceFlow.integrationEntitiesLens *< ies
    
    if case let .choosingIntegration(c, a, s, _, ies) = flow {
      state.flow = .choosingIntegration(c, a, s, .notRefreshing, ies)
    }
    
    return .none
  case .integrationEntitiesUpdated(.failure):
    if case let .choosingIntegration(c, st, s, _, ies) = state.flow {
      state.flow = .choosingIntegration(c, st, s, .notRefreshing, ies)
    }
    
    return .none
  case .liftedAddPlaceCoordinatePin:
    guard case let .choosingCoordinate(_, ies) = state.flow
    else { return environment.capture("Lifted a coordinate pin when not on a choosing coordinate map").fireAndForget() }
    
    state.flow = .choosingCoordinate(nil, ies)
    
    return .none
  case let .localSearchCompletionResultsUpdated(lss):
    guard case let .choosingAddress(c, st, ls, _, ies) = state.flow,
          ls == nil
    else { return .none }
    
    state.flow = .choosingAddress(c, st, nil, lss, ies)
    
    return .none
  case let .localSearchUpdated(r):
    guard case let .choosingAddress(c, .some(st), .some(ls), lss, ies) = state.flow else { return .none }
    
    switch r {
    case let .results(r) where r.count == 1:
      state.flow = .choosingIntegration(r.first.location, r.first.address, "", .notRefreshing, ies)
    case let .results(r):
      state.flow = .confirmingLocation(c, st, ls, r, lss, ies)
    case .empty:
      // TODO: Show alert for empty result
      state.flow = .choosingAddress(c, st, nil, lss, ies)
    case let .error(e):
      // TODO: Show alert for error
      state.flow = .choosingAddress(c, st, nil, lss, ies)
    case .fatalError:
      // TODO: Report and show an alert
      state.flow = .choosingAddress(c, st, nil, lss, ies)
    }
    
    return .none
  case let .placeCreated(r):
    guard case let .addingPlace(c, a, ie, ies) = state.flow
    else { return environment.capture("Place creation returned when user wasn't on the waiting screen").fireAndForget() }
    
    switch r {
    case .success: state.flow = nil
    case .failure: state.flow = .choosingIntegration(c, a, "", .notRefreshing, ies)
    }
    
    return .none
  case let .reverseGeocoded(gr):
    guard case let .choosingCoordinate(.some(oldGR), ies) = state.flow, oldGR.coordinate == gr.coordinate
    else { return .none }
    
    state.flow = .choosingCoordinate(gr, ies)
    
    return .none
  case .searchForIntegrations:
    guard case let .choosingIntegration(c, a, s, _, ies) = state.flow
    else { return environment.capture("Trying to search for integrations when not choosing an integration").fireAndForget()  }
    
    state.flow = .choosingIntegration(c, a, s, .refreshing, ies)
    
    return Effect(value: .updateIntegrations(s))
  case .searchPlaceByAddress:
    guard case let .choosingCoordinate(_, ies) = state.flow,
          let currentLocation = state.history?.coordinates.last
    else { return .none }
    
    state.flow = .choosingAddress(currentLocation, nil, nil, [], ies)
    
    return .none
  case .searchPlaceOnMap:
    guard case let .choosingAddress(c, _, _, _, ies) = state.flow
    else { return environment.capture("Trying to switch to map when searching places when not in search by address view").fireAndForget() }
    
    state.flow = .choosingCoordinate(.init(coordinate: state.history?.coordinates.last ?? c), ies)
    
    return .cancel(id: LocalSearchCompletionResultsSubscriptionID())
  case let .selectAddress(ls):
    guard case let .choosingAddress(c, .some(st), _, lss, ies) = state.flow
    else { return environment.capture("Trying to select an address when not in search by address view").fireAndForget() }
    
    state.flow = .choosingAddress(c, st, ls, lss, ies)
    
    return localSearch(ls, c)
  case let .selectPlace(p):
    guard case .choosingCoordinate = state.flow else { return .none }
    
    state.flow = nil
    
    return .none
  case let .selectedIntegration(ie):
    guard case let .choosingIntegration(c, a, s, _, ies) = state.flow
    else { return environment.capture("Trying to select the integration when not searching for integrations").fireAndForget() }
    
    state.flow = .addingPlace(c, a, ie, ies)
    
    return Effect(value: .createPlace(c, ie))
  case let .updateAddressSearch(st):
    guard case let .choosingAddress(c, _, ls, lss, ies) = state.flow
    else { return environment.capture("Updating address value when not in search by address view").fireAndForget() }
    
    state.flow = .choosingAddress(c, st, ls, lss, ies)
    
    return autocompleteLocalSearch(st, c)
  case .updateIntegrations:
    return .none
  case let .updateIntegrationsSearch(s):
    guard case let .choosingIntegration(c, a, _, r, ies) = state.flow
    else { return environment.capture("Trying to update integration search when not searching for integrations").fireAndForget() }
    
    state.flow = .choosingIntegration(c, a, s, r, ies)
    
    return .none
  case let .updatedAddPlaceCoordinate(c):
    guard case let .choosingCoordinate(_, ies) = state.flow
    else { return environment.capture("Trying to update the place coordinate when not adding place").fireAndForget() }
    
    state.flow = .choosingCoordinate(.init(coordinate: c), ies)
    
    return reverseGeocode(c)
  }
}
.onEntry(
  chooseAddressState,
  send: { _, e in
    subscribeToLocalSearchCompletionResults(
      s: e.subscribeToLocalSearchCompletionResults,
      main: e.mainQueue
    )
  }
)
.onExit(
  chooseAddressState,
  send: constant(.cancel(id: LocalSearchCompletionResultsSubscriptionID()))
)


func chooseAddressState(_ state: AddPlaceState) -> Terminal? {
  state *^? \.flow ** Optional.prism ** /AddPlaceFlow.choosingAddress
    <¡> constant(unit)
}

func reverseGeocode(
  rge: @escaping (Coordinate) -> Effect<GeocodedResult, Never>,
  main: AnySchedulerOf<DispatchQueue>
) -> (Coordinate) -> Effect<AddPlaceAction, Never> {
  { c in
    rge(c)
      .map(AddPlaceAction.reverseGeocoded)
      .receive(on: main)
      .eraseToEffect()
  }
}

struct LocalSearchCompletionResultsSubscriptionID: Hashable {}

func subscribeToLocalSearchCompletionResults(
  s: @escaping () -> Effect<[LocalSearchCompletion], Never>,
  main: AnySchedulerOf<DispatchQueue>
) -> Effect<AddPlaceAction, Never> {
  s()
    .map(AddPlaceAction.localSearchCompletionResultsUpdated)
    .receive(on: main)
    .eraseToEffect()
    .cancellable(id: LocalSearchCompletionResultsSubscriptionID(), cancelInFlight: true)
}

func autocompleteLocalSearch(
  als: @escaping (Street?, Coordinate) -> Effect<Never, Never>,
  main: AnySchedulerOf<DispatchQueue>
) -> (Street?, Coordinate) -> Effect<AddPlaceAction, Never> {
  { st, c in
    als(st, c)
      .fireAndForget()
      .receive(on: main)
      .eraseToEffect()
  }
}

struct LocalSearchID: Hashable {}

func localSearch(
  ls: @escaping (LocalSearchCompletion, Coordinate) -> Effect<LocalSearchResult, Never>,
  main: AnySchedulerOf<DispatchQueue>
) -> (LocalSearchCompletion, Coordinate) -> Effect<AddPlaceAction, Never> {
  { lsc, c in
    ls(lsc, c)
      .map(AddPlaceAction.localSearchUpdated)
      .receive(on: main)
      .eraseToEffect()
      .cancellable(id: LocalSearchID(), cancelInFlight: true)
  }
}
