import ComposableArchitecture
import Types


// MARK: - Action

public enum SDKStatusUpdateAction: Equatable {
  case statusUpdated(SDKStatusUpdate)
}

// MARK: - Reducer

public let sdkStatusUpdateReducer: Reducer<SDKStatusUpdate, SDKStatusUpdateAction, Void> = Reducer { state, action, _ in
  switch action {
  case let .statusUpdated(s):
    
    state = s
    
    return .none
  }
}
