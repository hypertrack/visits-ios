import AppArchitecture
import AppStartupLogic
import ComposableArchitecture
import Utility
import Types


let appStartupP: Reducer<
  AppState,
  AppAction,
  SystemEnvironment<AppEnvironment>
> = appStartupReducer.pullback(
  state: appStartupStateAffine,
  action: appStartupActionPrism,
  environment: \.errorReporting.capture >>> AppStartupEnvironment.init(capture:)
)

func appStartedState(_ appState: AppState) -> Terminal? {
  switch appState {
  case let .launching(l):
    switch (l.stateAndSDK, l.visibility) {
    case (.starting, .some): return unit
    default:                 return .none
    }
  default:                   return .none
  }
}

private let appStartupStateAffine = appStartupStatePrism ** appStartupStateLens

private let appStartupActionPrism = Prism<AppAction, AppStartupAction>(
  extract: { appAction in
    switch appAction {
    case .generated(.entered(.started)): return .start
    default:                             return nil
    }
  },
  embed: { appStartupAction in
    switch appStartupAction {
    case .start: return .generated(.entered(.started))
    }
  }
)

private enum AppStartupDomain {
  case starting(RestoredState, SDKStatusUpdate, AppVisibility)
  case operational(RestoredState, SDKStatusUpdate, AppVisibility)
}

private let appStartupStatePrism = Prism<AppState, AppStartupDomain>(
  extract: { s in
    switch s {
    case let .launching(l):
      switch (l.stateAndSDK, l.visibility) {
      case let (.starting(rs, sdk), .some(v)): return .starting(rs, sdk, v)
      default:                                 return .none
      }
    case let .operational(o) where o.alert == nil:
      let flow: StorageState.Flow
      switch o.flow {
      case .firstRun: flow = .firstRun
      case let .signIn(.entering(eg)) where eg.password == nil
                                         && eg.focus    == nil
                                         && eg.error    == nil:
        flow = .signIn(eg.email)
      case let .main(m) where m.map                == .initialState
                           && m.trip               == nil
                           && m.places             == nil
                           && m.selectedPlace      == nil
                           && m.placesPresentation == .byPlace
                           && m.selectedOrderId    == nil
                           && m.requests           == []
                           && m.token              == nil
                           && m.history            == nil
                           && m.profile.metadata   == [:]
                           && m.integrationStatus  == .unknown:
        flow = .main(m.tab, m.publishableKey, m.profile.name)
      default:
        return nil
      }
      return .operational(
        .init(
          storage: .init(
            experience: o.experience,
            flow: flow,
            locationAlways: o.locationAlways,
            pushStatus: o.pushStatus
          ),
          version: o.version
        ),
        o.sdk,
        o.visibility
      )
    default:
      return nil
    }
  },
  embed: { d in
    switch d {
    case let .starting(rs, sdk, v):
      return .launching(.init(stateAndSDK: .starting(rs, sdk), visibility: v))
    case let .operational(rs, sdk, v):
      let flow: AppFlow
      switch rs.storage.flow {
      case .firstRun:
        flow = .firstRun
      case let .signIn(e):
        flow = .signIn(.entering(.init(email: e)))
      case let .main(ts, pk, n):
        flow = .main(.init(map: .initialState, trip: nil, places: nil, tab: ts, publishableKey: pk, profile: .init(name: n, metadata: [:])))
      }
      return .operational(
        .init(
          alert: nil,
          experience: rs.storage.experience,
          flow: flow,
          locationAlways: sdk.permissions.locationPermissions == .notDetermined ? .notRequested : rs.storage.locationAlways,
          pushStatus: rs.storage.pushStatus,
          sdk: sdk,
          version: rs.version,
          visibility: v
        )
      )
    }
  }
)

private let appStartupStateLens = Lens<AppStartupDomain, AppStartupState>(
  get: { appStartupDomain in
    switch appStartupDomain {
    case .starting:    return .stopped
    case .operational: return .started
    }
  },
  set: { appStartupState in
    { appStartupDomain in
      switch (appStartupState, appStartupDomain) {
      case let (.started, .starting(rs, sdk, v)):    return .operational(rs, sdk, v)
      case let (.stopped, .operational(rs, sdk, v)): return .starting(rs, sdk, v)
      case     (.started, .operational),
               (.stopped, .starting):                return appStartupDomain
      }
    }
  }
)
