import AppArchitecture
import ComposableArchitecture
import Utility
import Types

// MARK: - Action

public enum OrderAction: Equatable {
  case focusNote
  case dismissFocus
  case cancelOrder
  case requestOrderCancel(Order)
  case orderCanceled(Order, Result<Terminal, APIError<Token.Expired>>)
  case completeOrder
  case requestOrderComplete(Order)
  case orderCompleted(Order, Result<Terminal, APIError<Token.Expired>>)
  case noteChanged(Order.Note?)
}

// MARK: - Environment

public struct OrderEnvironment {
  public var capture: (CaptureMessage) -> Effect<Never, Never>
  public var notifySuccess: () -> Effect<Never, Never>
  
  public init(capture: @escaping (CaptureMessage) -> Effect<Never, Never>, notifySuccess: @escaping () -> Effect<Never, Never>) {
    self.capture = capture; self.notifySuccess = notifySuccess
  }
}

// MARK: - Reducer

public let orderReducer = Reducer<Order, OrderAction, SystemEnvironment<OrderEnvironment>> { state, action, environment in
  
  switch action {
  case .focusNote:
    guard case let .ongoing(noteFocus) = state.status
    else { return environment.capture("Can't focus order note when it's not ongoing").fireAndForget() }
    
    state.status = .ongoing(.focused)
    
    return .none
  case .dismissFocus:
    guard case let .ongoing(noteFocus) = state.status
    else { return environment.capture("Can't dismiss order note focus when it's not ongoing").fireAndForget() }
    
    state.status = .ongoing(.unfocused)
    
    return .none
  case .cancelOrder:
    guard case .ongoing = state.status
    else { return environment.capture("Can't cancel order when it's not ongoing").fireAndForget() }

    state.status = .cancelling

    return .init(value: .requestOrderCancel(state))
  case .requestOrderCancel:
    return .none
  case let .orderCanceled(_, r):
    guard state.status == .cancelling
    else { return environment.capture("Can't process order cancellation because its status is not .cancelling").fireAndForget() }

    switch r {
    case .success: state.status = .cancelled
    case .failure: state.status = .ongoing(.unfocused)
    }

    return .none
  case .completeOrder:
    guard case .ongoing = state.status
    else { return environment.capture("Can't complete order when it's not ongoing").fireAndForget() }

    state.status = .completing

    return .init(value: .requestOrderComplete(state))
  case .requestOrderComplete:
    return .none
  case let .orderCompleted(_, r):
    guard state.status == .cancelling
    else { return environment.capture("Can't process order completion because its status is not .completing").fireAndForget() }

    switch r {
    case .success: state.status = .completed(environment.date())
    case .failure: state.status = .ongoing(.unfocused)
    }

    return .none
  case let .noteChanged(n):
    state.note = n
    
    return .none
  }
}
