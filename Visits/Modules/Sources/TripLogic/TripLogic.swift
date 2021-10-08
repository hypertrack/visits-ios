import AppArchitecture
import ComposableArchitecture
import IdentifiedCollections
import OrderLogic
import Utility
import Types
import NonEmpty


// MARK: - State

public struct TripState: Equatable {

  public var trip: Trip?
  public var selectedOrderId: Order.ID?
  
  public init(trip: Trip?, selectedOrderId: Order.ID? = nil) {
    self.trip = trip
    self.selectedOrderId = selectedOrderId
  }
}

// MARK: - Action

public enum TripAction: Equatable {
  case order(id: Order.ID, action: OrderAction)
  case selectOrder(Order.ID?)
  case tripUpdated(Trip?)
}

// MARK: - Reducer

public let tripReducer = Reducer<TripState, TripAction, SystemEnvironment<OrderEnvironment>>.combine(
  orderReducer.forEach(
    state: \.trip!.orders,
    action: /TripAction.order(id:action:),
    environment: { e in
      e.map { e in
        .init(
          capture: e.capture,
          notifySuccess: e.notifySuccess
        )
      }
    }
  ),
  Reducer { state, action, _ in    
    switch action {
    case .tripUpdated(let trip):
      state.trip = trip
    case .selectOrder(let selectedOrderId):
      state.selectedOrderId = selectedOrderId
    case .order(let id, let action):
      break
    }
    return .none
  }
)
