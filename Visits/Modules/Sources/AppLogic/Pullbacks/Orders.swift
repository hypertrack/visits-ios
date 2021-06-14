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

private let ordersStateAffine = /AppState.operational ** ordersStateOperationalAffine

private let ordersStateOperationalAffine = Affine<OperationalState, OrdersState>(
  extract: { s in
    switch (s.sdk.status, s.flow) {
    case let (.unlocked(deID, _), .main(main)):
      return .init(
        orders: main.orders,
        selected: main.selectedOrder,
        deviceID: deID,
        publishableKey: main.publishableKey
      )
    default:
      return nil
    }
  },
  inject: { d in
    { s in
      switch (s.sdk.status, s.flow) {
      case let (.unlocked(_, us), .main(main)):
        return s |> \.sdk.status *< .unlocked(d.deviceID, us)
          <> \.flow *< .main(
            main |> \.orders *< d.orders
              <> \.selectedOrder *< d.selected
              <> \.publishableKey *< d.publishableKey
          )
      default:
        return nil
      }
    }
  }
)

private let ordersActionPrism = Prism<AppAction, OrdersAction>(
  extract: { a in
    switch a {
    case     .focusOrderNote:              return .order(.focusNote)
    case     .dismissFocus:                return .order(.dismissFocus)
    case     .cancelOrder:                 return .order(.cancel)
    case let .orderCancelFinished(r):      return .order(.cancelFinished(r))
    case     .checkOutOrder:               return .order(.complete)
    case let .orderCompleteFinished(r):    return .order(.completeFinished(r))
    case let .orderNoteChanged(n):         return .order(.noteChanged(n <¡> Order.Note.init(rawValue:)))
    case     .openAppleMaps:               return .order(.openAppleMaps)
    case let .selectOrder(str):            return .selectOrder(str)
    case     .deselectOrder:               return .deselectOrder
    case let .ordersUpdated(.success(os)): return .ordersUpdated(os)
    default:                               return nil
    }
  },
  embed: { a in
    switch a {
    case     .order(.focusNote):           return .focusOrderNote
    case     .order(.dismissFocus):        return .dismissFocus
    case     .order(.cancel):              return .cancelOrder
    case let .order(.cancelFinished(r)):   return .orderCancelFinished(r)
    case     .order(.complete):            return .checkOutOrder
    case let .order(.completeFinished(r)): return .orderCompleteFinished(r)
    case let .order(.noteChanged(n)):      return .orderNoteChanged(n?.rawValue)
    case     .order(.openAppleMaps):       return .openAppleMaps
    case let .selectOrder(str):            return .selectOrder(str)
    case     .deselectOrder:               return .deselectOrder
    case let .ordersUpdated(os):           return .ordersUpdated(.success(os))
    }
  }
)

private func toOrdersEnvironment(_ e: SystemEnvironment<AppEnvironment>) -> SystemEnvironment<OrdersEnvironment> {
  e.map { e in
    .init(
      cancelOrder: e.api.cancelOrder,
      completeOrder: e.api.completeOrder,
      notifySuccess: e.hapticFeedback.notifySuccess,
      openMap: e.maps.openMap
    )
  }
}
