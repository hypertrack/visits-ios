import AppArchitecture
import ComposableArchitecture
import Prelude
import Types


// MARK: - Action

public enum OrderAction: Equatable {
  case focusNote
  case dismissFocus
  case cancel
  case complete
  case pickUp
  case noteChanged(Order.OrderNote?)
  case openAppleMaps
}

// MARK: - Environment

public struct OrderEnvironment {
  public var addGeotag: (Geotag) -> Effect<Never, Never>
  public var notifySuccess: () -> Effect<Never, Never>
  public var openMap: (Coordinate, Either<FullAddress, Street>?) -> Effect<Never, Never>
  
  public init(
    addGeotag: @escaping (Geotag) -> Effect<Never, Never>,
    notifySuccess: @escaping () -> Effect<Never, Never>,
    openMap: @escaping (Coordinate, Either<FullAddress, Street>?) -> Effect<Never, Never>
  ) {
    self.addGeotag = addGeotag
    self.notifySuccess = notifySuccess
    self.openMap = openMap
  }
}

// MARK: - Reducer

public let orderReducer = Reducer<Order, OrderAction, SystemEnvironment<OrderEnvironment>> { state, action, environment in
  
  func addGeotag(_ geotag: Geotag) -> Effect<OrderAction, Never> {
    .merge(
      environment.addGeotag(geotag).fireAndForget(),
      environment.notifySuccess().fireAndForget()
    )
  }
  
  switch action {
  case .focusNote:
    state.noteFieldFocused = true
    
    return .none
  case .dismissFocus:
    state.noteFieldFocused = false
    
    return .none
  case .cancel:
    guard state.geotagSent.checkedOut == nil,
          state.geotagSent.cancelled == nil
    else { return .none }
    
    state.geotagSent = .cancelled(state.geotagSent.isVisited, environment.date())
    
    return addGeotag(.cancel(state.id, state.source, state.orderNote))
  case .complete:
    guard state.geotagSent.checkedOut == nil,
          state.geotagSent.cancelled == nil
    else { return .none }
    
    state.geotagSent = .checkedOut(state.geotagSent.isVisited, environment.date())
    
    return addGeotag(.checkOut(state.id, state.source, state.orderNote))
  case .pickUp:
    guard state.geotagSent == .notSent else { return .none }
    
    state.geotagSent = .pickedUp
    
    return addGeotag(.pickUp(state.id, state.source))
  case let .noteChanged(n):
    state.orderNote = n
    
    return .none
  case .openAppleMaps:
    let add: Either<FullAddress, Street>?
    switch (state.address.fullAddress, state.address.street) {
    case     (.none, .none): add = .none
    case let (.some(f), _):  add = .left(f)
    case let (_, .some(s)):  add = .right(s)
    }
    return environment.openMap(state.location, add).fireAndForget()
  }
}
