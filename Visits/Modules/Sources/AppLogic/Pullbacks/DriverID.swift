import AppArchitecture
import ComposableArchitecture
import DriverIDLogic
import Utility
import Types


let driverIDP: Reducer<
  AppState,
  AppAction,
  SystemEnvironment<AppEnvironment>
> = driverIDReducer.pullback(
  state: driverIDStateAffine,
  action: driverIDActionPrism,
  environment: { $0.map(\.hyperTrack.makeSDK >>> DriverIDEnvironment.init(makeSDK:)) }
)

private let driverIDStateAffine = /AppState.operational ** \.flow ** /AppFlow.driverID

private let driverIDActionPrism = Prism<AppAction, DriverIDAction>(
  extract: { a in
    switch a {
    case let .driverIDChanged(drID): return .driverIDChanged(drID)
    case     .setDriverID:           return .setDriverID
    case let .madeSDK(s):            return .madeSDK(s)
    default:                         return nil
    }
  },
  embed: { a in
    switch a {
    case let .driverIDChanged(drID): return .driverIDChanged(drID)
    case     .setDriverID:           return .setDriverID
    case let .madeSDK(s):            return .madeSDK(s)
    }
  }
)
