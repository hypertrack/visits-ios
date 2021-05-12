import ComposableArchitecture
import Types


// MARK: - Action

public enum TabAction: Equatable {
  case switchTo(TabSelection)
}

// MARK: - Reducer

public let tabReducer = Reducer<TabSelection, TabAction, Void> { state, action, _ in
  switch action {
  case let .switchTo(ts):
    guard state != ts else { return .none }
    
    state = ts
    
    return .none
  }
}
