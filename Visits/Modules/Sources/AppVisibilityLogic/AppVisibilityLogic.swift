import ComposableArchitecture
import Types


// MARK: - Action

public enum AppVisibilityAction { case appVisibilityChanged(AppVisibility) }

// MARK: - Reducer

public let appVisibilityReducer = Reducer<AppVisibility, AppVisibilityAction, Void> { state, action, _ in
  switch action {
  case let .appVisibilityChanged(v):
    state = v
    
    return .none
  }
}
