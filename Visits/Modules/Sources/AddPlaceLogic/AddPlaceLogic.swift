import AppArchitecture
import ComposableArchitecture
import Types
import Utility


// MARK: - State

public struct AddPlaceState: Equatable {
  public var flow: AddPlaceFlow?
  public var history: History?
  
  public init(flow: AddPlaceFlow? = nil, history: History?) { self.flow = flow; self.history = history }
}

// MARK: - Action

public enum AddPlaceAction: Equatable {
  case addPlace
  case cancelAddPlace
  case cancelChoosingCompany
  case confirmAddPlaceCoordinate
  case createPlace(Coordinate, IntegrationEntity)
  case integrationEntitiesUpdated(Result<[IntegrationEntity], APIError<Token.Expired>>)
  case liftedAddPlaceCoordinatePin
  case placeCreated(Result<Place, APIError<Token.Expired>>)
  case reverseGeocoded(GeocodedResult)
  case searchForIntegrations
  case selectPlace(Place)
  case selectedIntegration(IntegrationEntity)
  case updateIntegrations(Search)
  case updateIntegrationsSearch(Search)
  case updatedAddPlaceCoordinate(Coordinate)
}

// MARK: - Environment

public struct AddPlaceEnvironment {
  public var capture: (CaptureMessage) -> Effect<Never, Never>
  public var reverseGeocode: (Coordinate) -> Effect<GeocodedResult, Never>
  
  public init(
    capture: @escaping (CaptureMessage) -> Effect<Never, Never>,
    reverseGeocode: @escaping (Coordinate) -> Effect<GeocodedResult, Never>
  ) {
    self.capture = capture
    self.reverseGeocode = reverseGeocode
  }
}

// MARK: - Reducer

public let addPlaceReducer = Reducer<AddPlaceState, AddPlaceAction, SystemEnvironment<AddPlaceEnvironment>> { state, action, environment in
  let reverseGeocode = reverseGeocode(rge: environment.reverseGeocode, main: environment.mainQueue)
  
  switch action {
  case .addPlace:
    guard state.flow == nil
    else { return environment.capture("Can't add place when already adding place").fireAndForget() }
    
    let lastCoordinate = state.history?.coordinates.last
    let setCoordinateWithAddressNone = .none |> flip(curry(GeocodedResult.init(coordinate:address:)))
      
    state.flow = .choosingCoordinate(lastCoordinate.map(setCoordinateWithAddressNone), [])
    
    return .merge(
      lastCoordinate.map(reverseGeocode) ?? .none,
      Effect(value: .updateIntegrations(""))
    )
  case .cancelAddPlace:
    guard state.flow != nil
    else { return environment.capture("Trying to cancel adding place when already canceled").fireAndForget() }
    
    state.flow = nil
    
    return .none
  case .cancelChoosingCompany:
    guard case let .choosingIntegration(c, s, _, _, ies) = state.flow
    else { return environment.capture("Trying to cancel choosing company when not choosing company").fireAndForget() }
    
    state.flow = .choosingCoordinate(.init(coordinate: c, address: .init(street: s)), ies)
    
    return .none
  case .confirmAddPlaceCoordinate:
    guard case let .choosingCoordinate(.some(gr), ies) = state.flow
    else { return environment.capture("Trying to confirm a place coordinate without a coordinate").fireAndForget() }
        
    state.flow = .choosingIntegration(gr.coordinate, gr.address.street, "", .notRefreshing, ies)
    
    return .none
  case .createPlace:
    return .none
  case let .integrationEntitiesUpdated(.success(ies)):
    switch state.flow {
    case .none:                                    break
    case let .choosingCoordinate(gr, _):           state.flow = .choosingCoordinate(gr, ies)
    case let .choosingIntegration(c, st, s, _, _): state.flow = .choosingIntegration(c, st, s, .notRefreshing, ies)
    case let .addingPlace(c, st, ie, s, _):        state.flow = .addingPlace(c, st, ie, s, ies)
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
  case let .placeCreated(r):
    guard case let .addingPlace(c, st, _, s, ies) = state.flow
    else { return environment.capture("Place creation returned when user wasn't on the waiting screen").fireAndForget() }
    
    switch r {
    case .success: state.flow = nil
    case .failure: state.flow = .choosingIntegration(c, st, s, .notRefreshing, ies)
    }
    
    return .none
  case let .reverseGeocoded(gr):
    guard case let .choosingCoordinate(.some(oldGR), ies) = state.flow, oldGR.coordinate == gr.coordinate
    else { return .none }
    
    state.flow = .choosingCoordinate(gr, ies)
    
    return .none
  case .searchForIntegrations:
    guard case let .choosingIntegration(c, st, s, r, ies) = state.flow
    else { return environment.capture("Trying to search for integrations when not choosing an integration").fireAndForget() }
    
    state.flow = .choosingIntegration(c, st, s, .refreshing, ies)
    
    return Effect(value: .updateIntegrations(s))
  case let .selectPlace(p):
    guard case .choosingCoordinate = state.flow else { return .none }
    
    state.flow = nil
    
    return .none
  case let .selectedIntegration(ie):
    guard case let .choosingIntegration(c, st, s, _, ies) = state.flow
    else { return environment.capture("Trying to select the integration when not searching for integrations").fireAndForget() }
    
    state.flow = .addingPlace(c, st, ie, s, ies)
    
    return Effect(value: .createPlace(c, ie))
  case .updateIntegrations:
    return .none
  case let .updateIntegrationsSearch(s):
    guard case let .choosingIntegration(c, st, _, r, ies) = state.flow
    else { return environment.capture("Trying to update integration search when not searching for integrations").fireAndForget() }
    
    state.flow = .choosingIntegration(c, st, s, r, ies)
    
    return .none
  case let .updatedAddPlaceCoordinate(c):
    guard case let .choosingCoordinate(_, ies) = state.flow
    else { return environment.capture("Trying to update the place coordinate when not adding place").fireAndForget() }
    
    state.flow = .choosingCoordinate(.init(coordinate: c), ies)
    
    return reverseGeocode(c)
  }
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
