import ComposableArchitecture
import Types


// MARK: - Action

public enum AppVisibilityStartupAction { case appVisibilityChanged(AppVisibility) }

// MARK: - Reducer

public let appVisibilityStartupReducer = Reducer<AppVisibility?, AppVisibilityStartupAction, Void> { state, action, _ in
  switch action {
  case let .appVisibilityChanged(v):
    state = v
    
    return .none
  }
}
