import AppArchitecture
import ComposableArchitecture
import Utility
import RefreshingLogic
import Types


let refreshingP: Reducer<
  AppState,
  AppAction,
  SystemEnvironment<AppEnvironment>
> = refreshingReducer.pullback(
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

private let refreshingStateOperationalAffine = Affine<OperationalState, RefreshingState>(
  extract: { s in
    switch (s.flow, s.sdk.status) {
    case let (.main(m), .unlocked(deID, _)):
      return .init(refreshing: m.refreshing, deviceID: deID, publishableKey: m.publishableKey)
    default:
      return nil
    }
  },
  inject: { s in
    { d in
      switch (d.flow, d.sdk.status) {
      case let (.main(m), .unlocked(_, us)):
        return d |> \.flow *< .main(m |> \.publishableKey *< s.publishableKey <> \.refreshing *< s.refreshing)
                 <> \.sdk.status *< .unlocked(s.deviceID, us)
      default:
        return nil
      }
    }
  }
)

private let refreshingActionPrism = Prism<AppAction, RefreshingAction>(
  extract: { a in
    switch a {
    case let .appVisibilityChanged(v):               return .appVisibilityChanged(v)
    case     .receivedPushNotification:              return .receivedPushNotification
    case     .generated(.entered(.mainUnlocked)):    return .mainUnlocked
    case     .startTracking:                         return .startTracking
    case     .stopTracking:                          return .stopTracking
    case     .updateOrders:                          return .updateOrders
    case     .switchToOrders:                        return .switchToOrders
    case let .ordersUpdated(os):                     return .ordersUpdated(os)
    case     .orderCancelFinished(.success(unit)):   return .orderCanceled
    case     .orderCompleteFinished(.success(unit)): return .orderCompleted
    case     .updatePlaces:                          return .updatePlaces
    case     .switchToPlaces:                        return .switchToPlaces
    case let .placesUpdated(ps):                     return .placesUpdated(ps)
    case     .switchToMap:                           return .switchToMap
    case let .historyUpdated(h):                     return .historyUpdated(h)
    default:                                         return nil
    }
  },
  embed: { a in
    switch a {
    case let .appVisibilityChanged(v):            return .appVisibilityChanged(v)
    case     .receivedPushNotification:           return .receivedPushNotification
    case     .mainUnlocked:                       return .generated(.entered(.mainUnlocked))
    case     .startTracking:                      return .startTracking
    case     .stopTracking:                       return .stopTracking
    case     .updateOrders:                       return .updateOrders
    case     .orderCanceled:                      return .orderCancelFinished(.success(unit))
    case     .orderCompleted:                     return .orderCompleteFinished(.success(unit))
    case     .switchToOrders:                     return .switchToOrders
    case let .ordersUpdated(os):                  return .ordersUpdated(os)
    case     .updatePlaces:                       return .updatePlaces
    case     .switchToPlaces:                     return .switchToPlaces
    case let .placesUpdated(ps):                  return .placesUpdated(ps)
    case     .switchToMap:                        return .switchToMap
    case let .historyUpdated(h):                  return .historyUpdated(h)
    }
  }
)

private func toRefreshingEnvironment(_ e: SystemEnvironment<AppEnvironment>) -> SystemEnvironment<RefreshingEnvironment> {
  e.map { e in
    .init(
      getHistory:     e.api.getHistory,
      getOrders:      e.api.getOrders,
      getPlaces:      e.api.getPlaces,
      reverseGeocode: e.api.reverseGeocode
    )
  }
}
