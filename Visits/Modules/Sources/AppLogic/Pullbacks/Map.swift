import AppArchitecture
import ComposableArchitecture
import MapLogic
import MapDependency
import Types
import Utility


let mapP: Reducer<
  AppState,
  AppAction,
  SystemEnvironment<AppEnvironment>
> = mapReducer.pullback(
  state: /AppState.operational ** \.flow ** /AppFlow.main ** \.map,
  action: mapActionPrism,
  environment: toMapEnvironment
)

private func toMapEnvironment(_ e: SystemEnvironment<AppEnvironment>) -> MapEnvironment {
  .init(
    capture: e.errorReporting.capture,
    openMap: e.maps.openMap
  )
}

private let mapActionPrism = Prism<AppAction, MapAction>(
  extract: { a in
    switch a {
    case     .mapRegionWillChange: return .regionWillChange
    case     .mapRegionDidChange:  return .regionDidChange
    case     .mapEnableAutoZoom:   return .enableAutoZoom
    case let .openInMaps(c, a):    return .openInMaps(c, a)
    default:                       return nil
    }
  },
  embed: { a in
    switch a {
    case     .regionWillChange: return .mapRegionWillChange
    case     .regionDidChange:  return .mapRegionDidChange
    case     .enableAutoZoom:   return .mapEnableAutoZoom
    case let .openInMaps(c, a): return .openInMaps(c, a)
    }
  }
)
