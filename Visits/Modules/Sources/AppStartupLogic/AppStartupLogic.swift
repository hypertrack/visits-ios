import ComposableArchitecture


// MARK: - State

public enum AppStartupState { case stopped, started }

// MARK: - Action

public enum AppStartupAction { case start }

// MARK: - Reducer

public let appStartupReducer: Reducer<AppStartupState, AppStartupAction, Void> = Reducer { state, action, _ in
  switch action {
  case .start:
    guard state == .stopped else { return .none }
    
    state = .started
    
    return .none
  }
}
