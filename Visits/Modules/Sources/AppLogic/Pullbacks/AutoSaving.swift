import AppArchitecture
import AutoSavingLogic
import ComposableArchitecture
import Prelude
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
  case let .signUp(.form(f)):
    switch f.status {
    case let .filling(f): flow = .signUp(f.email)
    case let .filled(f):  flow = .signUp(f.email)
    }
  case let .signUp(.questions(q)): flow = .signUp(q.email)
  case let .signUp(.verification(v)): flow = .signUp(v.email)
  case let .signIn(.entering(e)): flow = .signIn(e.email)
  case let .signIn(.entered(e)): flow = .signIn(e.email)
  case let .driverID(d):
    switch d.status {
    case let .entering(drID): flow = .driverID(drID, d.publishableKey)
    case let .entered(drID): flow = .driverID(drID, d.publishableKey)
    }
  case let .main(m): flow = .main(
    m.selectedOrder.map { Set.insert($0)(m.orders) } ?? m.orders,
    m.places,
    m.tab,
    m.publishableKey,
    m.driverID
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
