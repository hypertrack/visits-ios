import AppArchitecture
import ComposableArchitecture
import Prelude
import SDKStatusUpdateLogic
import Types


let sdkStatusUpdateP: Reducer<
  AppState,
  AppAction,
  SystemEnvironment<AppEnvironment>
> = sdkStatusUpdateReducer.pullback(
  state: sdkStatusUpdateStateAffine,
  action: sdkStatusUpdateActionPrism,
  environment: constant(())
)

private let sdkStatusUpdateStateAffine: Affine<AppState, SDKStatusUpdate> = /AppState.operational ** \.sdk

private let sdkStatusUpdateActionPrism: Prism<AppAction, SDKStatusUpdateAction> = .init(
  extract: { appAction in
    switch appAction {
    case let .statusUpdated(s): return .statusUpdated(s)
    default:                       return nil
    }
  },
  embed: { sdkStatusUpdateAction in
    switch sdkStatusUpdateAction {
    case let .statusUpdated(s): return .statusUpdated(s)
    }
  }
)

