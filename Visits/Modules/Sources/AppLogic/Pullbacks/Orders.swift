import AppArchitecture
import ComposableArchitecture
import NonEmpty
import OrdersLogic
import Prelude
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

private let ordersStateAffine = /AppState.operational ** \.flow ** /AppFlow.main ** ordersStateLens

private let ordersActionPrism = Prism<AppAction, OrdersAction>(
  extract: { a in
    switch a {
    case     .focusOrderNote:      return .order(.focusNote)
    case     .dismissFocus:        return .order(.dismissFocus)
    case     .cancelOrder:         return .order(.cancel)
    case     .checkOutOrder:       return .order(.complete)
    case     .pickUpOrder:         return .order(.pickUp)
    case let .orderNoteChanged(n): return .order(.noteChanged(n <¡> Order.OrderNote.init(rawValue:)))
    case     .openAppleMaps:       return .order(.openAppleMaps)
    case let .selectOrder(str):    return .selectOrder(str)
    case     .deselectOrder:       return .deselectOrder
    case let .ordersUpdated(.success(os)):
      switch NonEmptyDictionary(rawValue: os) {
      case let .some(os):          return .ordersUpdated(os)
      default:                     return nil
      }
    case let .reverseGeocoded(g):  return .reverseGeocoded(g)
    default:                       return nil
    }
  },
  embed: { a in
    switch a {
    case     .order(.focusNote):      return .focusOrderNote
    case     .order(.dismissFocus):   return .dismissFocus
    case     .order(.cancel):         return .cancelOrder
    case     .order(.complete):       return .checkOutOrder
    case     .order(.pickUp):         return .pickUpOrder
    case let .order(.noteChanged(n)): return .orderNoteChanged(n?.rawValue)
    case     .order(.openAppleMaps):  return .openAppleMaps
    case let .selectOrder(str):       return .selectOrder(str)
    case     .deselectOrder:          return .deselectOrder
    case let .ordersUpdated(os):      return .ordersUpdated(.success(os.rawValue))
    case let .reverseGeocoded(g):     return .reverseGeocoded(g)
    }
  }
)

private let ordersStateLens = Lens<MainState, OrdersState>(
  get: { d in
    .init(orders: d.orders, selected: d.selectedOrder)
  },
  set: { s in
    \MainState.orders *< s.orders <> \.selectedOrder *< s.selected
  }
)

private func toOrdersEnvironment(_ e: SystemEnvironment<AppEnvironment>) -> SystemEnvironment<OrdersEnvironment> {
  e.map { e in
    .init(
      addGeotag: e.hyperTrack.addGeotag,
      notifySuccess: e.hapticFeedback.notifySuccess,
      openMap: e.maps.openMap,
      reverseGeocode: e.api.reverseGeocode
    )
  }
}
