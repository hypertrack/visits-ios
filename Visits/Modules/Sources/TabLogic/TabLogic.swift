import ComposableArchitecture
import Types


// MARK: - Action

public enum TabAction: Equatable {
  case selectOrder(Order)
  case selectPlace(Place)
  case switchTo(TabSelection)
}

// MARK: - Reducer

public let tabReducer = Reducer<TabSelection, TabAction, Void> { state, action, _ in
  switch action {
  case let .switchTo(ts):
    guard state != ts else { return .none }
    
    state = ts
    
    return .none
  case .selectOrder:
    guard state != .orders else { return .none }
    
    state = .orders
    
    return .none
  case .selectPlace:
    guard state != .places else { return .none }
    
    state = .places
    
    return .none
  }
}
