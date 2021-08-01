import AppArchitecture
import AutoSavingLogic
import ComposableArchitecture
import Utility
import Types


let autoSavingP: Reducer<
  AppState,
  AppAction,
  SystemEnvironment<AppEnvironment>
> = autoSavingReducer.pullback(
  state: autoSavingStateAffine,
  action: autoSavingActionPrism,
  environment: \.stateRestoration.saveState >>> AutoSavingEnvironment.init(saveState:)
)

func toStorageState(_ a: AppState) -> StorageState? {
  a *^? /AppState.operational <¡> toStorageState
}

private func toStorageState(_ o: OperationalState) -> StorageState {
  let flow: StorageState.Flow
  switch o.flow {
  case .firstRun:
    flow = .firstRun
  case let .signIn(.entering(e)): flow = .signIn(e.email)
  case let .signIn(.entered(e)): flow = .signIn(e.email)
  case let .main(m): flow = .main(
    m.places,
    m.tab,
    m.publishableKey,
    m.profile.name
  )
  }
  return .init(
    experience: o.experience,
    flow: flow,
    locationAlways: o.locationAlways,
    pushStatus: o.pushStatus
  )
}

private let autoSavingStateAffine = /AppState.operational ** Lens.void()

private let autoSavingActionPrism = Prism<AppAction, AutoSavingAction>(
  extract: { a in
    switch a {
    case let .generated(.changed(.storage(ss))): return .save(ss)
    default:                                     return nil
    }
  },
  embed: { a in
    switch a {
    case let .save(ss): return .generated(.changed(.storage(ss)))
    }
  }
)

extension Set {
  static func insert(_ newMember: Element) -> (Self) -> Self {
    { set in
      var set = set
      set.insert(newMember)
      return set
    }
  }
}
