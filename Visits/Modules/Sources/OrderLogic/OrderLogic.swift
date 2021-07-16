import AppArchitecture
import ComposableArchitecture
import Utility
import Types

// MARK: - Action

public enum OrderAction: Equatable {
  case focusNote
  case dismissFocus
  case cancelSelectedOrder
  case cancelOrder(Order)
  case completeSelectedOrder
  case completeOrder(Order)
  case noteChanged(Order.Note?)
  case openAppleMaps
}

// MARK: - Environment

public struct OrderEnvironment {
  public var capture: (CaptureMessage) -> Effect<Never, Never>
  public var notifySuccess: () -> Effect<Never, Never>
  public var openMap: (Coordinate, Either<FullAddress, Street>?) -> Effect<Never, Never>
  
  public init(capture: @escaping (CaptureMessage) -> Effect<Never, Never>, notifySuccess: @escaping () -> Effect<Never, Never>, openMap: @escaping (Coordinate, Either<FullAddress, Street>?) -> Effect<Never, Never>) {
    self.capture = capture; self.notifySuccess = notifySuccess; self.openMap = openMap
  }
}

// MARK: - Reducer

public let orderReducer = Reducer<Order, OrderAction, SystemEnvironment<OrderEnvironment>> { state, action, environment in
  
  switch action {
  case .focusNote:
    guard case let .ongoing(noteFocus) = state.status else { return environment.capture("Can't focus order note when it's not ongoing").fireAndForget() }
    
    state.status = .ongoing(.focused)
    
    return .none
  case .dismissFocus:
    guard case let .ongoing(noteFocus) = state.status else { return environment.capture("Can't dismiss order note focus when it's not ongoing").fireAndForget() }
    
    state.status = .ongoing(.unfocused)
    
    return .none
  case .cancelSelectedOrder:
    guard case .ongoing = state.status else { return environment.capture("Can't cancel order when it's not ongoing").fireAndForget() }
    
    return .init(value: .cancelOrder(state))
  case .cancelOrder:
    return .none
  case .completeSelectedOrder:
    guard case .ongoing = state.status else { return environment.capture("Can't complete order when it's not ongoing").fireAndForget() }
    
    return .init(value: .completeOrder(state))
  case .completeOrder:
    return .none
  case let .noteChanged(n):
    state.note = n
    
    return .none
  case .openAppleMaps:
    let add: Either<FullAddress, Street>?
    switch (state.address.fullAddress, state.address.street) {
    case     (.none, .none): add = .none
    case let (.some(f), _):  add = .left(f)
    case let (_, .some(s)):  add = .right(s)
    }
    return environment.openMap(state.location, add)
      .fireAndForget()
  }
}
