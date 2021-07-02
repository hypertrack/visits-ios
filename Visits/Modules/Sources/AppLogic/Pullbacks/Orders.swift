import AppArchitecture
import ComposableArchitecture
import NonEmpty
import OrdersLogic
import Utility
import Types


let ordersP: Reducer<
  AppState,
  AppAction,
  SystemEnvironment<AppEnvironment>
> = ordersReducer.pullback(
  state: ordersStateAffine,
  action: ordersActionPrism,
  environment: toOrdersEnvironment
)

private let ordersStateAffine = /AppState.operational ** \.flow ** /AppFlow.main ** ordersStateMainLens

private let ordersStateMainLens = Lens<MainState, OrdersState>(
  get: { s in
    .init(
      orders: s.orders,
      selected: s.selectedOrder
    )
  },
  set: { d in
     \.orders *< d.orders <> \.selectedOrder *< d.selected
  }
)

private let ordersActionPrism = Prism<AppAction, OrdersAction>(
  extract: { a in
    switch a {
    case     .focusOrderNote:              return .order(.focusNote)
    case     .dismissFocus:                return .order(.dismissFocus)
    case     .cancelSelectedOrder:         return .order(.cancelSelectedOrder)
    case let .cancelOrder(o):              return .order(.cancelOrder(o))
    case     .completeSelectedOrder:       return .order(.completeSelectedOrder)
    case let .checkOutOrder(o):            return .order(.completeOrder(o))
    case let .orderNoteChanged(n):         return .order(.noteChanged(n <¡> Order.Note.init(rawValue:)))
    case     .openAppleMaps:               return .order(.openAppleMaps)
    case let .selectOrder(o):              return .selectOrder(o)
    case     .deselectOrder:               return .deselectOrder
    case let .ordersUpdated(.success(os)): return .ordersUpdated(os)
    default:                               return nil
    }
  },
  embed: { a in
    switch a {
    case     .order(.focusNote):              return .focusOrderNote
    case     .order(.dismissFocus):           return .dismissFocus
    case     .order(.cancelSelectedOrder):    return .cancelSelectedOrder
    case let .order(.cancelOrder(o)):         return .cancelOrder(o)
    case     .order(.completeSelectedOrder):  return .completeSelectedOrder
    case let .order(.completeOrder(o)):       return .checkOutOrder(o)
    case let .order(.noteChanged(n)):         return .orderNoteChanged(n?.rawValue)
    case     .order(.openAppleMaps):          return .openAppleMaps
    case let .selectOrder(o):                 return .selectOrder(o)
    case     .deselectOrder:                  return .deselectOrder
    case let .ordersUpdated(os):              return .ordersUpdated(.success(os))
    }
  }
)

private func toOrdersEnvironment(_ e: SystemEnvironment<AppEnvironment>) -> SystemEnvironment<OrdersEnvironment> {
  e.map { e in
    .init(
      notifySuccess: e.hapticFeedback.notifySuccess,
      openMap: e.maps.openMap
    )
  }
}
