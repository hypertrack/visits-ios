import AppArchitecture
import ComposableArchitecture
import Utility
import Types

// MARK: - State

public struct OrderState: Equatable {
  public var order: Order
  public var deviceID: DeviceID
  public var publishableKey: PublishableKey
  
  public init(order: Order, deviceID: DeviceID, publishableKey: PublishableKey) {
    self.order = order; self.deviceID = deviceID; self.publishableKey = publishableKey
  }
}

// MARK: - Action

public enum OrderAction: Equatable {
  case focusNote
  case dismissFocus
  case cancel
  case cancelFinished(Result<Terminal, APIError<Never>>)
  case complete
  case completeFinished(Result<Terminal, APIError<Never>>)
  case noteChanged(Order.Note?)
  case openAppleMaps
}

// MARK: - Environment

public struct OrderEnvironment {
  public var cancelOrder: (PublishableKey, DeviceID, Order) -> Effect<Result<Terminal, APIError<Never>>, Never>
  public var completeOrder: (PublishableKey, DeviceID, Order) -> Effect<Result<Terminal, APIError<Never>>, Never>
  public var notifySuccess: () -> Effect<Never, Never>
  public var openMap: (Coordinate, Either<FullAddress, Street>?) -> Effect<Never, Never>
  
  public init(
    cancelOrder: @escaping (PublishableKey, DeviceID, Order) -> Effect<Result<Terminal, APIError<Never>>, Never>,
    completeOrder: @escaping (PublishableKey, DeviceID, Order) -> Effect<Result<Terminal, APIError<Never>>, Never>,
    notifySuccess: @escaping () -> Effect<Never, Never>,
    openMap: @escaping (Coordinate, Either<FullAddress, Street>?) -> Effect<Never, Never>
  ) {
    self.cancelOrder = cancelOrder
    self.completeOrder = completeOrder
    self.notifySuccess = notifySuccess
    self.openMap = openMap
  }
}

// MARK: - Reducer

public let orderReducer = Reducer<OrderState, OrderAction, SystemEnvironment<OrderEnvironment>> { state, action, environment in
  
  switch action {
  case .focusNote:
    guard case let .ongoing(noteFocus) = state.order.status else { return .none }
    
    state.order.status = .ongoing(.focused)
    
    return .none
  case .dismissFocus:
    guard case let .ongoing(noteFocus) = state.order.status else { return .none }
    
    state.order.status = .ongoing(.unfocused)
    
    return .none
  case .cancel:
    guard case .ongoing = state.order.status else { return .none }
    
    state.order.status = .cancelling
    
    return environment.cancelOrder(state.publishableKey, state.deviceID, state.order)
      .map(OrderAction.cancelFinished)
  case let .cancelFinished(result):
    guard case .cancelling = state.order.status else { return .none }
    
    switch result {
    case .success: state.order.status = .cancelled
    case .failure: state.order.status = .ongoing(.unfocused)
    }
    
    return .none
  case .complete:
    guard case .ongoing = state.order.status else { return .none }
    
    state.order.status = .completing
    
    return environment.completeOrder(state.publishableKey, state.deviceID, state.order)
      .map(OrderAction.completeFinished)
  case let .completeFinished(result):
    guard case .completing = state.order.status else { return .none }
    
    switch result {
    case .success: state.order.status = .completed(environment.date())
    case .failure: state.order.status = .ongoing(.unfocused)
    }
    
    return .none
  case let .noteChanged(n):
    state.order.note = n
    
    return .none
  case .openAppleMaps:
    let add: Either<FullAddress, Street>?
    switch (state.order.address.fullAddress, state.order.address.street) {
    case     (.none, .none): add = .none
    case let (.some(f), _):  add = .left(f)
    case let (_, .some(s)):  add = .right(s)
    }
    return environment.openMap(state.order.location, add).fireAndForget()
  }
}
