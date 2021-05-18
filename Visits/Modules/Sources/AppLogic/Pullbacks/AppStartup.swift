import AppArchitecture
import AppStartupLogic
import ComposableArchitecture
import Prelude
import Types


let appStartupP: Reducer<
  AppState,
  AppAction,
  SystemEnvironment<AppEnvironment>
> = appStartupReducer.pullback(
  state: appStartupStateAffine,
  action: appStartupActionPrism,
  environment: constant(())
)

func appStartedState(_ appState: AppState) -> Prelude.Unit? {
  switch appState {
  case .starting: return unit
  default:        return nil
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
  case starting(RestoredState, SDKStatusUpdate)
  case operational(RestoredState, SDKStatusUpdate)
}

private let appStartupStatePrism = Prism<AppState, AppStartupDomain>(
  extract: { appState in
    switch appState {
    case let .starting(rs, sdk):
      return .starting(rs, sdk)
    case let .operational(o) where o.alert == nil:
      let flow: StorageState.Flow
      switch o.flow {
      case .firstRun: flow = .firstRun
      case let .signIn(.entering(eg)) where eg.password == nil
                                         && eg.focus    == nil
                                         && eg.error    == nil:
        flow = .signIn(eg.email)
      case let .driverID(d):
        switch d.status {
        case let .entering(drID):
          flow = .driverID(drID, d.publishableKey)
        default:
          return .none
        }
      case let .main(m):
        flow = .main(m.orders, m.places, m.tab, m.publishableKey, m.driverID)
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
        o.sdk
      )
    default:
      return nil
    }
  },
  embed: { appStartupDomain in
    switch appStartupDomain {
    case let .starting(ss, sdk):
      return .starting(ss, sdk)
    case let .operational(rs, su):
      let flow: AppFlow
      switch rs.storage.flow {
      case .firstRun:
        flow = .firstRun
      case let .signIn(e):
        flow = .signIn(.entering(.init(email: e)))
      case let .driverID(drID, pk):
        flow = .driverID(.init(status: .entering(drID), publishableKey: pk))
      case let .main(os, ps, ts, pk, drID):
        flow = .main(.init(orders: os, places: ps, tab: ts, publishableKey: pk, driverID: drID, refreshing: .none))
      }
      return .operational(
        .init(
          alert: nil,
          experience: rs.storage.experience,
          flow: flow,
          locationAlways: rs.storage.locationAlways,
          pushStatus: rs.storage.pushStatus,
          sdk: su,
          version: rs.version
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
      case let (.started, .starting(ss, su)):    return .operational(ss, su)
      case let (.stopped, .operational(ss, su)): return .starting(ss, su)
      case     (.started, .operational),
               (.stopped, .starting):            return appStartupDomain
      }
    }
  }
)
