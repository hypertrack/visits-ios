import AppArchitecture
import ComposableArchitecture
import MapLogic
import Types
import Utility


let mapP: Reducer<
  AppState,
  AppAction,
  SystemEnvironment<AppEnvironment>
> = mapReducer.pullback(
  state: /AppState.operational ** \.flow ** /AppFlow.main ** \.map,
  action: mapActionPrism,
  environment: \.errorReporting.capture >>> MapEnvironment.init(capture:)
)


private let mapActionPrism = Prism<AppAction, MapAction>(
  extract: { a in
    switch a {
    case .mapRegionWillChange: return .regionWillChange
    case .mapRegionDidChange:  return .regionDidChange
    case .mapEnableAutoZoom:   return .enableAutoZoom
    default:                   return nil
    }
  },
  embed: { a in
    switch a {
    case .regionWillChange: return .mapRegionWillChange
    case .regionDidChange:  return .mapRegionDidChange
    case .enableAutoZoom:   return .mapEnableAutoZoom
    }
  }
)
