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
  case updatedAddPlaceCoordinate(Coordinate)
}

// MARK: - Environment

public struct AddPlaceEnvironment {
  public var capture: (CaptureMessage) -> Effect<Never, Never>
  
  public init(
    capture: @escaping (CaptureMessage) -> Effect<Never, Never>
  ) {
    self.capture = capture
  }
}

// MARK: - Reducer

public let addPlaceReducer = Reducer<AddPlaceState, AddPlaceAction, AddPlaceEnvironment> { state, action, environment in
  switch action {
  case .addPlace:
    guard state.flow == nil
    else { return environment.capture("Can't add place when already adding place").fireAndForget() }
    
    state.flow = .init(placeCoordinate: state.history?.coordinates.last)
    
    return .none
  case .cancelAddPlace:
    guard state.flow != nil
    else { return environment.capture("Trying to cancel adding place when already canceled").fireAndForget() }
    
    state.flow = nil
    
    return .none
  case let .updatedAddPlaceCoordinate(c):
    guard let flow = state.flow
    else { return environment.capture("Trying to update the place coordinate when not adding place").fireAndForget() }
    
    state.flow = flow |> \.placeCoordinate *< c
    
    return .none
  }
}
