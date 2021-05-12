import ComposableArchitecture
import Types


// MARK: - Action

public enum HistoryAction: Equatable {
  case historyUpdated(History)
}

// MARK: - Reducer

public let historyReducer = Reducer<History?, HistoryAction, Void> { state, action, _ in
  switch action {
  case let .historyUpdated(h):
    state = h
    
    return .none
  }
}
