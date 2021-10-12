import AppArchitecture
import ComposableArchitecture
import NonEmpty
import TripLogic
import OrderLogic
import Utility
import Types


let tripP: Reducer<
  AppState,
  AppAction,
  SystemEnvironment<AppEnvironment>
> = tripReducer.pullback(
  state: tripStateAffine,
  action: tripActionPrism,
  environment: toOrderEnvironment
)

private let tripStateAffine = /AppState.operational ** \.flow ** /AppFlow.main ** tripStateMainLens

private let tripStateMainLens = Lens<MainState, TripState>(
  get: { s in
    .init(
      trip: s.trip,
      selectedOrderId: s.selectedOrderId
    )
  },
  set: { d in
     \.trip *< d.trip <> \.selectedOrderId *< d.selectedOrderId
  }
)

private let tripActionPrism = Prism<AppAction, TripAction>(
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
    case let .tripUpdated(.success(t)):   return .tripUpdated(t)
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
    case let .tripUpdated(t):                return .tripUpdated(.success(t))
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
