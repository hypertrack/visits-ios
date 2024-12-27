import AppArchitecture
import ComposableArchitecture
import Utility
import TabLogic
import Types


let tabP: Reducer<
  AppState,
  AppAction,
  SystemEnvironment<AppEnvironment>
> = tabReducer.pullback(
  state: tabStateAffine,
  action: tabActionPrism,
  environment: constant(())
)

private let tabStateAffine = /AppState.operational ** \.flow ** /AppFlow.main ** \.tab

private let tabActionPrism = Prism<AppAction, TabAction>(
  extract: { a in
    switch a {
    case let .selectOrder(.some(o)): return .selectOrder(o)
    case let .selectPlace(.some(p)): return .selectPlace(p)
    case     .switchToMap:           return .switchTo(.map)
    case     .switchToOrders:        return .switchTo(.orders)
    case     .switchToPlaces:        return .switchTo(.places)
    case     .switchToProfile:       return .switchTo(.profile)
    case     .switchToVisits:       return .switchTo(.visits)
    default:                         return nil
    }
  },
  embed: { a in
    switch a {
    case let .selectOrder(o):     return .selectOrder(o)
    case let .selectPlace(p):     return .selectPlace(p)
    case     .switchTo(.map):     return .switchToMap
    case     .switchTo(.orders):  return .switchToOrders
    case     .switchTo(.places):  return .switchToPlaces
    case     .switchTo(.profile): return .switchToProfile
    case     .switchTo(.visits): return .switchToVisits
    }
  }
)
