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
  environment: \.hyperTrack.setDriverID
    >>> SDKInitializationEnvironment.init(setDriverID:)
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
  var alert: Either<AlertState<ErrorAlertAction>, AlertState<ErrorReportingAlertAction>>?
  var driverID: DriverID
  var experience: Experience
  var flow: SDKInitializationFlowDomain
  var locationAlways: LocationAlwaysPermissions
  var publishableKey: PublishableKey
  var pushStatus: PushStatus
  var sdk: SDKStatusUpdate
  var appVersion: AppVersion
  var visibility: AppVisibility
}

private enum SDKInitializationFlowDomain {
  case signIn(Password)
  case driverID
  case initialized
}

private let sdkInitializationStatePrism = Prism<AppState, SDKInitializationDomain>(
  extract: { appState in
    switch appState {
    case let .operational(s):
      let flow: SDKInitializationFlowDomain
      let driverID: DriverID
      let publishableKey: PublishableKey
      
      switch s.flow {
      case let .signIn(.entered(ed)):
        switch ed.request {
        case let .success(pk):
          flow = .signIn(ed.password)
          driverID = rewrap(ed.email)
          publishableKey = pk
        default:
          return nil
        }
      case let .driverID(d):
        switch d.status {
        case let .entered(drID):
          flow = .driverID
          driverID = drID
          publishableKey = d.publishableKey
        default:
          return nil
        }
      case let .main(m) where m.orders == []
                           && m.selectedOrder == nil
                           && m.places == []
                           && m.tab == .defaultTab
                           && m.refreshing == .none:
        flow = .initialized
        driverID = m.driverID
        publishableKey = m.publishableKey
      default:
        return nil
      }
     
      return .init(
        alert: s.alert,
        driverID: driverID,
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
    case let .signIn(p):
      flow = .signIn(
        .entered(
          .init(email: rewrap(d.driverID), password: p, request: .success(d.publishableKey))
        )
      )
    case .driverID:
      flow = .driverID(.init(status: .entered(d.driverID), publishableKey: d.publishableKey))
    case .initialized:
      flow = .main(.init(map: .initialState, orders: [], places: [], tab: .defaultTab, publishableKey: d.publishableKey, driverID: d.driverID, refreshing: .none))
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
    switch s.flow {
    case let .signIn(p):     return .uninitialized(s.driverID, .signIn(p))
    case     .driverID:      return .uninitialized(s.driverID, .driverID)
    case     .initialized:   return .initialized(s.sdk)
    }
  },
  set: { s in
    { d in
      let flow: SDKInitializationFlowDomain
      let driverID: DriverID
      let statusUpdate: SDKStatusUpdate
      
      switch s {
      case let .uninitialized(drID, source):
        switch source {
        case let .signIn(p):     flow = .signIn(p)
        case     .driverID:      flow = .driverID
        }
        driverID = drID
        statusUpdate = d.sdk
      case let .initialized(sdk):
        flow = .initialized
        driverID = d.driverID
        statusUpdate = sdk
      }
      
      return d |> \.flow *< flow
        <> \.driverID *< driverID
        <> \.sdk *< statusUpdate
    }
  }
)

private func rewrap<Source, Value, Destination>(_ source: Tagged<Source, Value>) -> Tagged<Destination, Value> {
  .init(rawValue: source.rawValue)
}
