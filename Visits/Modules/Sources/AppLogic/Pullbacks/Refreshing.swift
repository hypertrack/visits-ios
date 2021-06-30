import AppArchitecture
import ComposableArchitecture
import Utility
import RequestLogic
import Types


let requestP: Reducer<
  AppState,
  AppAction,
  SystemEnvironment<AppEnvironment>
> = requestReducer.pullback(
  state: refreshingStateAffine,
  action: refreshingActionPrism,
  environment: toRefreshingEnvironment
)

func mainUnlocked(_ a: AppState) -> Terminal? {
  a *^? /AppState.operational
    >>- { o in
      switch (o.flow, o.pushStatus, o.sdk.permissions, o.sdk.status) {
      case (.main, .dialogSplash(.shown), .granted, .unlocked(_, .running)):
        return unit
      default:
        return nil
      }
    }
}

private let refreshingStateAffine = /AppState.operational ** refreshingStateOperationalAffine

private let refreshingStateOperationalAffine = Affine<OperationalState, RequestState>(
  extract: { s in
    switch (s.flow, s.sdk.status) {
    case let (.main(m), .unlocked(deID, _)):
      return .init(requests: m.requests, deviceID: deID, publishableKey: m.publishableKey, token: m.token)
    default:
      return nil
    }
  },
  inject: { d in
    { s in
      switch (s.flow, s.sdk.status) {
      case let (.main(m), .unlocked(_, us)):
        return s |> \.flow *< .main(m |> \.publishableKey *< d.publishableKey <> \.requests *< d.requests <> \.token *< d.token)
                 <> \.sdk.status *< .unlocked(d.deviceID, us)
      default:
        return nil
      }
    }
  }
)

private let refreshingActionPrism = Prism<AppAction, RequestAction>(
  extract: { a in
    switch a {
    case let .appVisibilityChanged(v):               return .appVisibilityChanged(v)
    case let .cancelOrder(o):                        return .cancelOrder(o)
    case let .checkOutOrder(o):                      return .completeOrder(o)
    case let .historyUpdated(r):                     return .historyUpdated(r)
    case     .generated(.entered(.mainUnlocked)):    return .mainUnlocked
    case let .orderCancelFinished(o, r):             return .orderCanceled(o, r)
    case let .orderCompleteFinished(o, r):           return .orderCompleted(o, r)
    case let .ordersUpdated(os):                     return .ordersUpdated(os)
    case let .placesUpdated(ps):                     return .placesUpdated(ps)
    case     .receivedPushNotification:              return .receivedPushNotification
    case     .startTracking:                         return .startTracking
    case     .stopTracking:                          return .stopTracking
    case     .switchToMap:                           return .switchToMap
    case     .switchToOrders:                        return .switchToOrders
    case     .switchToPlaces:                        return .switchToPlaces
    case let .tokenUpdated(r):                       return .tokenUpdated(r)
    case     .updateOrders:                          return .updateOrders
    case     .updatePlaces:                          return .updatePlaces
    default:                                         return nil
    }
  },
  embed: { a in
    switch a {
    case let .appVisibilityChanged(v):  return .appVisibilityChanged(v)
    case let .cancelOrder(o):           return .cancelOrder(o)
    case let .completeOrder(o):         return .checkOutOrder(o)
    case let .historyUpdated(r):        return .historyUpdated(r)
    case     .mainUnlocked:             return .generated(.entered(.mainUnlocked))
    case let .orderCanceled(o, r):      return .orderCancelFinished(o, r)
    case let .orderCompleted(o, r):     return .orderCompleteFinished(o, r)
    case let .ordersUpdated(os):        return .ordersUpdated(os)
    case let .placesUpdated(ps):        return .placesUpdated(ps)
    case     .receivedPushNotification: return .receivedPushNotification
    case     .startTracking:            return .startTracking
    case     .stopTracking:             return .stopTracking
    case     .switchToMap:              return .switchToMap
    case     .switchToOrders:           return .switchToOrders
    case     .switchToPlaces:           return .switchToPlaces
    case let .tokenUpdated(r):          return .tokenUpdated(r)
    case     .updateOrders:             return .updateOrders
    case     .updatePlaces:             return .updatePlaces
    }
  }
)

private func toRefreshingEnvironment(_ e: SystemEnvironment<AppEnvironment>) -> SystemEnvironment<RequestEnvironment> {
  e.map { e in
    .init(
      cancelOrder:    e.api.cancelOrder,
      completeOrder:  e.api.completeOrder,
      getHistory:     e.api.getHistory,
      getOrders:      e.api.getOrders,
      getPlaces:      e.api.getPlaces,
      getToken:       e.api.getToken,
      reverseGeocode: e.api.reverseGeocode
    )
  }
}
