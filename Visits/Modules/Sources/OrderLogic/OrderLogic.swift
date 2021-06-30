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
  case cancelFinished(Order, Result<Terminal, APIError<Token.Expired>>)
  case completeSelectedOrder
  case completeOrder(Order)
  case completeFinished(Order, Result<Terminal, APIError<Token.Expired>>)
  case noteChanged(Order.Note?)
  case openAppleMaps
}

// MARK: - Environment

public struct OrderEnvironment {
  public var notifySuccess: () -> Effect<Never, Never>
  public var openMap: (Coordinate, Either<FullAddress, Street>?) -> Effect<Never, Never>
  
  public init(
    notifySuccess: @escaping () -> Effect<Never, Never>,
    openMap: @escaping (Coordinate, Either<FullAddress, Street>?) -> Effect<Never, Never>
  ) {
    self.notifySuccess = notifySuccess
    self.openMap = openMap
  }
}

// MARK: - Reducer

public let orderReducer = Reducer<Order, OrderAction, SystemEnvironment<OrderEnvironment>> { state, action, environment in
  
  switch action {
  case .focusNote:
    guard case let .ongoing(noteFocus) = state.status else { preconditionFailure() }
    
    state.status = .ongoing(.focused)
    
    return .none
  case .dismissFocus:
    guard case let .ongoing(noteFocus) = state.status else { preconditionFailure() }
    
    state.status = .ongoing(.unfocused)
    
    return .none
  case .cancelSelectedOrder:
    guard case .ongoing = state.status else { preconditionFailure() }
    
    state.status = .cancelling
    
    return .init(value: .cancelOrder(state))
  case .cancelOrder:
    return .none
  case .cancelFinished(_, .success):
    guard case .cancelling = state.status else { preconditionFailure() }
    
    state.status = .cancelled
    
    return .none
  case .cancelFinished(_, .failure):
    guard case .cancelling = state.status else { preconditionFailure() }
    
    state.status = .ongoing(.unfocused)
    
    return .none
  case .completeSelectedOrder:
    guard case .ongoing = state.status else { preconditionFailure() }
    
    state.status = .completing
    
    return Effect(value: .completeOrder(state))
  case .completeOrder:
    return .none
  case .completeFinished(_, .success):
    guard case .completing = state.status else { preconditionFailure() }
    
    state.status = .completed(environment.date())
    
    return .none
  case .completeFinished(_, .failure):
    guard case .completing = state.status else { preconditionFailure() }
    
    state.status = .ongoing(.unfocused)
    
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
