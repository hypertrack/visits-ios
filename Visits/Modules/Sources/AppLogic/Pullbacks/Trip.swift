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
    case let .cancelOrder(oid):            return .order(id: oid, action: .cancelOrder)
    case let .requestOrderCancel(o):       return .order(id: o.id, action: .requestOrderCancel(o))
    case let .orderCancelFinished(o, r):   return .order(id: o.id, action: .orderCanceled(o, r))
    case let .completeOrder(oid):          return .order(id: oid, action: .completeOrder)
    case let .requestOrderComplete(o):     return .order(id: o.id, action: .requestOrderComplete(o))
    case let .orderCompleteFinished(o, r): return .order(id: o.id, action: .orderCompleted(o, r))
    case let .snoozeOrder(oid):            return .order(id: oid, action: .snoozeOrder)
    case let .requestOrderSnooze(o):       return .order(id: o.id, action: .requestOrderSnooze(o))
    case let .orderSnoozeFinished(o, r):   return .order(id: o.id, action: .orderSnoozed(o, r))
    case let .unsnoozeOrder(oid):          return .order(id: oid, action: .unsnoozeOrder)
    case let .requestOrderUnsnooze(o):     return .order(id: o.id, action: .requestOrderUnsnooze(o))
    case let .orderUnsnoozeFinished(o, r): return .order(id: o.id, action: .orderUnsnoozed(o, r))
    case let .orderNoteChanged(oid, n):    return .order(id: oid, action: .noteChanged(n <¡> Order.Note.init(rawValue:)))
    case let .selectOrder(o):              return .selectOrder(o)
    case let .tripUpdated(.success(t)):    return .tripUpdated(t)
    case     .resetInProgressOrders:       return .resetInProgressOrders
    default:                               return nil
    }
  },
  embed: { a in
    switch a {
    case let .order(oid, orderAction):
      switch orderAction {
      case     .focusNote:                 return .focusOrderNote(oid)
      case     .dismissFocus:              return .orderDismissFocus(oid)
      case     .cancelOrder:               return .cancelOrder(oid)
      case let .requestOrderCancel(o):     return .requestOrderCancel(o)
      case let .orderCanceled(o, r):       return .orderCancelFinished(o, r)
      case     .completeOrder:             return .completeOrder(oid)
      case let .requestOrderComplete(o):   return .requestOrderComplete(o)
      case let .orderCompleted(o, r):      return .orderCompleteFinished(o, r)
      case     .snoozeOrder:               return .snoozeOrder(oid)
      case let .requestOrderSnooze(o):     return .requestOrderSnooze(o)
      case let .orderSnoozed(o, r):        return .orderSnoozeFinished(o, r)
      case     .unsnoozeOrder:             return .unsnoozeOrder(oid)
      case let .requestOrderUnsnooze(o):   return .requestOrderUnsnooze(o)
      case let .orderUnsnoozed(o, r):      return .orderUnsnoozeFinished(o, r)
      case let .noteChanged(n):            return .orderNoteChanged(oid, n?.rawValue)
      }
    case let .selectOrder(o):              return .selectOrder(o)
    case let .tripUpdated(t):              return .tripUpdated(.success(t))
    case     .resetInProgressOrders:       return .resetInProgressOrders
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
