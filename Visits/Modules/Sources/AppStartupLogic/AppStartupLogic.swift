import ComposableArchitecture
import Types


// MARK: - State

public enum AppStartupState { case stopped, started }

// MARK: - Action

public enum AppStartupAction { case start }

// MARK: - Environment

public struct AppStartupEnvironment {
  public var capture: (CaptureMessage) -> Effect<Never, Never>
  
  public init(capture: @escaping (CaptureMessage) -> Effect<Never, Never>) {
    self.capture = capture
  }
}

// MARK: - Reducer

public let appStartupReducer: Reducer<AppStartupState, AppStartupAction, AppStartupEnvironment> = Reducer { state, action, environment in
  switch action {
  case .start:
    guard state == .stopped
    else { return environment.capture("Can't start the app when it's already started").fireAndForget() }
    
    state = .started
    
    return .none
  }
}
