import ComposableArchitecture
import Types
import Utility


// MARK: - State

public struct PlacesState: Equatable {
  public var places: PlacesSummary?
  public var selected: Place?
  public var presentation: PlacesPresentation
  
  public init(places: PlacesSummary? = nil, selected: Place? = nil, presentation: PlacesPresentation) { self.places = places; self.selected = selected; self.presentation = presentation }
}


// MARK: - Action

public enum PlacesAction: Equatable {
  case changePlacesPresentation(PlacesPresentation)
  case placeCreated(Place)
  case placesUpdated(PlacesSummary)
  case selectPlace(Place?)
}

// MARK: - Reducer

public let placesReducer = Reducer<PlacesState, PlacesAction, Void> { state, action, _ in
  switch action {
  case let .changePlacesPresentation(pp):
    state.presentation = pp

    return .none
  case let .placesUpdated(ps):
    state.places = ps
    
    return .none
  case let .selectPlace(p):
    state.selected = p
    
    return .none
  case let .placeCreated(p):
    guard let places = state.places else { return .none }

    state.places = places |> \.places *< (places.places |> Set<Place>.insert(p))
    state.selected = p
    
    return .none
  }
}
