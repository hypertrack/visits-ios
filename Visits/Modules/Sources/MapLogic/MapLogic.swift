import ComposableArchitecture
import Types


// MARK: - Action

public enum MapAction: Equatable {
  case regionWillChange
  case regionDidChange
  case enableAutoZoom
}

// MARK: - Environment

public struct MapEnvironment {
  public var capture: (CaptureMessage) -> Effect<Never, Never>
  
  public init(capture: @escaping (CaptureMessage) -> Effect<Never, Never>) {
    self.capture = capture
  }
}
// MARK: - Reducer

public let mapReducer = Reducer<
  MapState,
  MapAction,
  MapEnvironment
> { state, action, environment in
  switch action {
  case .regionWillChange, .regionDidChange:
    guard state.autoZoom == .enabled else { return .none }
    
    state.autoZoom = .disabled
    
    return .none
  case .enableAutoZoom:
    guard state.autoZoom == .disabled else { return environment.capture("Can't enable auto zoom if it's enabled").fireAndForget() }
    
    state.autoZoom = .enabled
    
    return .none
  }
}
