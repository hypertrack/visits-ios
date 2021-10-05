import AppArchitecture
import ComposableArchitecture
import NonEmpty
import OrdersLogic
import OrderLogic
import Utility
import Types


let ordersP: Reducer<
  AppState,
  AppAction,
  SystemEnvironment<AppEnvironment>
> = ordersReducer.pullback(
  state: ordersStateAffine,
  action: ordersActionPrism,
  environment: toOrderEnvironment
)

private let ordersStateAffine = /AppState.operational ** \.flow ** /AppFlow.main ** ordersStateMainLens

private let ordersStateMainLens = Lens<MainState, OrdersState>(
  get: { s in
    .init(
      orders: s.orders,
      selectedId: s.selectedOrderId
    )
  },
  set: { d in
     \.orders *< d.orders <> \.selectedOrderId *< d.selectedId
  }
)

private let ordersActionPrism = Prism<AppAction, OrdersAction>(
  extract: { a in
    switch a {
    case let .focusOrderNote(oid):         return .order(id: oid, action: .focusNote)
    case let .orderDismissFocus(oid):      return .order(id: oid, action: .dismissFocus)
    case let .cancelSelectedOrder(oid):    return .order(id: oid, action: .cancelSelectedOrder)
    case let .cancelOrder(o):              return .order(id: o.id, action: .cancelOrder(o))
    case let .completeSelectedOrder(oid):       return .order(id: oid, action: .completeSelectedOrder)
    case let .checkOutOrder(o):            return .order(id: o.id, action: .completeOrder(o))
    case let .orderNoteChanged(oid, n):    return .order(id: oid, action: .noteChanged(n <¡> Order.Note.init(rawValue:)))
    case let .selectOrder(o):              return .selectOrder(o)
    case let .ordersUpdated(.success(os)): return .ordersUpdated(os)
    default:                               return nil
    }
  },
  embed: { a in
    switch a {
    case let .order(oid, orderAction):
      switch orderAction {
      case     .focusNote:                      return .focusOrderNote(oid)
      case     .dismissFocus:                   return .orderDismissFocus(oid)
      case     .cancelSelectedOrder:            return .cancelSelectedOrder(oid)
      case let .cancelOrder(o):                 return .cancelOrder(o)
      case     .completeSelectedOrder:          return .completeSelectedOrder(oid)
      case let .completeOrder(o):               return .checkOutOrder(o)
      case let .noteChanged(n):                 return .orderNoteChanged(oid, n?.rawValue)
      }
    case let .selectOrder(o):                 return .selectOrder(o)
    case let .ordersUpdated(os):              return .ordersUpdated(.success(os))
    }
  }
)

private func toOrderEnvironment(_ e: SystemEnvironment<AppEnvironment>) -> SystemEnvironment<OrderEnvironment> {
   e.map { e in
     .init(
       capture: e.errorReporting.capture,
       notifySuccess: e.hapticFeedback.notifySuccess
     )
   }
 }
