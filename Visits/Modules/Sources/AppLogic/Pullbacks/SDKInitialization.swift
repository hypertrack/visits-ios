import AppArchitecture
import ComposableArchitecture
import Utility
import SDKInitializationLogic
import Tagged
import Types


let sdkInitializationP: Reducer<
  AppState,
  AppAction,
  SystemEnvironment<AppEnvironment>
> = sdkInitializationReducer.pullback(
  state: sdkInitializationStateAffine,
  action: sdkInitializationActionPrism,
  environment: toSDKInitializationEnvironment
)

private let sdkInitializationStateAffine = sdkInitializationStatePrism ** sdkInitializationStateLens

private let sdkInitializationActionPrism: Prism<AppAction, SDKInitializationAction> = .init(
  extract: { appAction in
    switch appAction {
    case let .madeSDK(s): return .initialize(s)
    default:              return nil
    }
  },
  embed: { sdkInitializationAction in
    switch sdkInitializationAction {
    case let .initialize(s): return .madeSDK(s)
    }
  }
)


private struct SDKInitializationDomain {
  var alert: Alert?
  var experience: Experience
  var flow: SDKInitializationState.Status
  var locationAlways: LocationAlwaysPermissions
  var publishableKey: PublishableKey
  var pushStatus: PushStatus
  var sdk: SDKStatusUpdate
  var appVersion: AppVersion
  var visibility: AppVisibility
}

private let sdkInitializationStatePrism = Prism<AppState, SDKInitializationDomain>(
  extract: { appState in
    switch appState {
    case let .operational(s):
      let flow: SDKInitializationState.Status
      let publishableKey: PublishableKey
      
      switch s.flow {
      case let .signIn(.entered(ed)):
        switch ed.request {
        case let .success(pk):
          flow = .uninitialized(ed.email, ed.password)
          publishableKey = pk
        default:
          return nil
        }
      case let .main(m) where m.map == .initialState
                           && m.orders == []
                           && m.selectedOrder == nil
                           && m.places == []
                           && m.history == nil
                           && m.tab == .defaultTab
                           && m.requests.isEmpty
                           && m.integrationStatus == .unknown
                           && m.token == nil:
        flow = .initialized(m.profile)
        publishableKey = m.publishableKey
      default:
        return nil
      }
     
      return .init(
        alert: s.alert,
        experience: s.experience,
        flow: flow,
        locationAlways: s.locationAlways,
        publishableKey: publishableKey,
        pushStatus: s.pushStatus,
        sdk: s.sdk,
        appVersion: s.version,
        visibility: s.visibility
      )
    default:
      return nil
    }
  },
  embed: { d in
    let flow: AppFlow
    switch d.flow {
    case let .uninitialized(e, p):
      flow = .signIn(
        .entered(
          .init(email: e, password: p, request: .success(d.publishableKey))
        )
      )
    case let .initialized(p):
      flow = .main(.init(map: .initialState, orders: [], places: [], tab: .defaultTab, publishableKey: d.publishableKey, profile: p))
    }
    
    return .operational(
      .init(
        alert: d.alert,
        experience: d.experience,
        flow: flow,
        locationAlways: d.locationAlways,
        pushStatus: d.pushStatus,
        sdk: d.sdk,
        version: d.appVersion,
        visibility: d.visibility
      )
    )
  }
)

private let sdkInitializationStateLens = Lens<SDKInitializationDomain, SDKInitializationState>(
  get: { s in
    .init(sdk: s.sdk, status: s.flow)
  },
  set: { s in
    \.flow *< s.status <> \.sdk *< s.sdk
  }
)

private func toSDKInitializationEnvironment(_ e: SystemEnvironment<AppEnvironment>) -> SDKInitializationEnvironment {
  .init(
    setName: e.hyperTrack.setName,
    setMetadata: e.hyperTrack.setMetadata
  )
}
