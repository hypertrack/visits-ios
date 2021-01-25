import Architecture
import ComposableArchitecture
import DriverID
import ManualVisitsStatus
import NonEmpty
import Prelude
import Tagged
import Visit

extension Visits {
  static let `default` = Visits.assigned([])
}

let deepLinkReducer: Reducer<AppState, AppAction, SystemEnvironment<AppEnvironment>> = Reducer { state, action, environment in
  
  struct TimerID: Hashable {}
  
  let timer = Effect.timer(
    id: TimerID(),
    every: 5,
    on: environment.mainQueue()
  )
  .map(constant(AppAction.deepLinkTimerFired))
  
  switch (state.flow, action) {
  case (.appLaunching, .restoredState(.left(.deepLink), _)):
    return timer
  case let (.driverID(_, _, _, .waitingForSDKWith(pk, drID, mvs)), .madeSDK(s, p)),
       let (.signIn(.editingCredentials(_, .right(.waitingForSDKWith(pk, drID, mvs)))), .madeSDK(s, p)):
    switch s {
    case .locked:
      state.flow = .noMotionServices
      return .none
    case let .unlocked(deID, s):
      switch mvs {
      case .none,
           .some(.hideManualVisits):
        state.flow = .visits(.default, nil, .visits, pk, drID, deID, s, p, nil, .dialogSplash(.notShown), .none)
      case .some(.showManualVisits):
        state.flow = .visits(.mixed([]), nil, .visits, pk, drID, deID, s, p, nil, .dialogSplash(.notShown), .none)
      }
      return .merge(
        environment
          .hyperTrack
          .subscribeToStatusUpdates()
          .receive(on: environment.mainQueue())
          .eraseToEffect()
          .map(AppAction.statusUpdated),
        environment
          .hyperTrack
          .setDriverID(drID)
          .fireAndForget()
      )
    }
  case let (.visits(_, _, _, _, _, _, _, _, _, ps, .waitingForSDKWith(pk, drID, mvs)), .madeSDK(s, p)):
    switch s {
    case .locked:
      state.flow = .noMotionServices
      return .none
    case let .unlocked(deID, s):
      switch mvs {
      case .none,
           .some(.hideManualVisits):
        state.flow = .visits(.default, nil, .visits, pk, drID, deID, s, p, nil, ps, .none)
      case .some(.showManualVisits):
        state.flow = .visits(.mixed([]), nil, .visits, pk, drID, deID, s, p, nil, ps, .none)
      }
      return .merge(
        environment
          .hyperTrack
          .subscribeToStatusUpdates()
          .receive(on: environment.mainQueue())
          .eraseToEffect()
          .map(AppAction.statusUpdated),
        environment
          .hyperTrack
          .setDriverID(drID)
          .fireAndForget()
      )
    }
  case let (.driverID(drID, pk, mvs, .none), .deepLinkOpened(a)):
    state.flow = .driverID(drID, pk, mvs, .waitingForDeepLink)
    return .merge(
      timer,
      environment
        .deepLink
        .continueUserActivity(a)
        .fireAndForget()
    )
  case let (.driverID(drID, pk, mvs, .none), .receivedDeepLink(dPK, dDRIDD, dMVS)):
    state.flow = .driverID(drID, pk, mvs, .waitingForTimerWith(dPK, dDRIDD, dMVS))
    return timer
  case let (.driverID(drID, pk, mvs, .waitingForDeepLink), .deepLinkTimerFired):
    state.flow = .driverID(drID, pk, mvs, .none)
    return .cancel(id: TimerID())
  case let (.driverID(drID, pk, mvs, .waitingForDeepLink), .receivedDeepLink(dPK, dDRIDD, dMVS)):
    state.flow = .driverID(drID, pk, mvs, .waitingForTimerWith(dPK, dDRIDD, dMVS))
    return .none
  case let (.driverID(drID, pk, mvs, .waitingForTimerWith(dPK, dDRIDD, dMVS)), .deepLinkTimerFired):
    let newMVS = dMVS ?? mvs
    if let dDRIDD = dDRIDD {
      state.flow = .driverID(dDRIDD, dPK, newMVS, .waitingForSDKWith(dPK, dDRIDD, newMVS))
      return .merge(
        .cancel(id: TimerID()),
        environment.hyperTrack
          .makeSDK(pk)
          .receive(on: environment.mainQueue())
          .eraseToEffect()
          .map(AppAction.madeSDK)
      )
    } else {
      state.flow = .driverID(drID, dPK, newMVS, .none)
      return .cancel(id: TimerID())
    }
  case let (.signIn(.editingCredentials(tep, .none)), .deepLinkOpened(a)),
       let (.signIn(.editingCredentials(tep, .left)), .deepLinkOpened(a)):
    state.flow = .signIn(.editingCredentials(tep, .right(.waitingForDeepLink)))
    return .merge(
      timer,
      environment.deepLink
        .continueUserActivity(a)
        .fireAndForget()
    )
  case let (.signIn(.editingCredentials(tep, .none)), .receivedDeepLink(pk, drID, mvs)),
       let (.signIn(.editingCredentials(tep, .left)), .receivedDeepLink(pk, drID, mvs)):
    state.flow = .signIn(.editingCredentials(tep, .right(.waitingForTimerWith(pk, drID, mvs))))
    return timer
  case let (.signIn(.editingCredentials(tep, .right(.waitingForDeepLink))), .deepLinkTimerFired):
    state.flow = .signIn(.editingCredentials(tep, .none))
    return .cancel(id: TimerID())
  case let (.signIn(.editingCredentials(tep, .right(.waitingForDeepLink))), .receivedDeepLink(pk, drID, mvs)):
    state.flow = .signIn(.editingCredentials(tep, .right(.waitingForTimerWith(pk, drID, mvs))))
    return .none
  case let (.signIn(.editingCredentials(tep, .right(.waitingForTimerWith(pk, drID, mvs)))), .deepLinkTimerFired):
    if let drID = drID {
      state.flow = .signIn(.editingCredentials(tep, .right(.waitingForSDKWith(pk, drID, mvs))))
      return .merge(
        .cancel(id: TimerID()),
        environment.hyperTrack
          .makeSDK(pk)
          .receive(on: environment.mainQueue())
          .eraseToEffect()
          .map(AppAction.madeSDK)
      )
    } else {
      state.flow = .driverID(nil, pk, mvs, nil)
      return .cancel(id: TimerID())
    }
  case let (.visits(v, h, s, vPK, vDRID, deID, us, p, _, ps, .none), .deepLinkOpened(a)):
    state.flow = .visits(v, h, s, vPK, vDRID, deID, us, p, .none, ps, .waitingForDeepLink)
    return .merge(
      timer,
      environment
        .deepLink
        .continueUserActivity(a)
        .fireAndForget()
    )
  case let (.visits(v, h, s, vPK, vDRID, deID, us, p, _, ps, .none), .receivedDeepLink(pk, drID, mvs)):
    state.flow = .visits(v, h, s, vPK, vDRID, deID, us, p, .none, ps, .waitingForTimerWith(pk, drID, mvs))
    return timer
  case let (.visits(v, h, s, vPK, vDRID, deID, us, p, _, ps, .waitingForDeepLink), .receivedDeepLink(pk, drID, mvs)):
    state.flow = .visits(v, h, s, vPK, vDRID, deID, us, p, .none, ps, .waitingForTimerWith(pk, drID, mvs))
    return .none
  case let (.visits(v, h, s, vPK, vDRID, deID, us, p, _, ps, .waitingForDeepLink), .deepLinkTimerFired):
    state.flow = .visits(v, h, s, vPK, vDRID, deID, us, p, .none, ps, .none)
    return .cancel(id: TimerID())
  case let (.visits(v, h, s, vPK, vDRID, deID, us, p, _, ps, .waitingForTimerWith(pk, drID, mvs)), .deepLinkTimerFired):
    
    let vMVS: ManualVisitsStatus
    switch v {
    case .mixed,
         .selectedMixed:
      vMVS = .showManualVisits
    default:
      vMVS = .hideManualVisits
    }
    let rMVS = mvs ?? vMVS
    
    state.flow = .visits(v, h, s, vPK, vDRID, deID, us, p, .none, ps, .none)
    
    switch (v, vPK, vDRID, pk, drID, mvs) {
    case let (_, vPK, _, pk, .none, .none) where vPK == pk:
      return .cancel(id: TimerID())
    case let (_, vPK, vDRID, pk, .some(drID), .none) where vPK == pk && vDRID == drID:
      return .cancel(id: TimerID())
    case let (_, vPK, vDRID, pk, .some(drID), .none) where vPK == pk && vDRID != drID:
      state.flow = .visits(v, h, s, pk, drID, deID, us, p, .none, ps, .none)
      return .merge(
        .cancel(id: TimerID()),
        environment
          .hyperTrack
          .setDriverID(drID)
          .fireAndForget()
      )
    case let (.mixed, vPK, vDRID, pk, drID, .some(.showManualVisits)) where vPK == pk,
         let (.selectedMixed, vPK, vDRID, pk, drID, .some(.showManualVisits)) where vPK == pk,
         let (.assigned, vPK, vDRID, pk, drID, .some(.hideManualVisits)) where vPK == pk,
         let (.selectedAssigned, vPK, vDRID, pk,drID, .some(.hideManualVisits)) where vPK == pk:
      if let drID = drID, drID != vDRID {
        state.flow = .visits(v, h, s, pk, drID, deID, us, p, .none, ps, .none)
        return .merge(
          .cancel(id: TimerID()),
          environment
            .hyperTrack
            .setDriverID(drID)
            .fireAndForget()
        )
      } else {
        return .cancel(id: TimerID())
      }
    case let (.mixed(v), vPK, vDRID, pk, drID, .some(.hideManualVisits)) where vPK == pk:
      let newDRID: DriverID
      if let drID = drID, drID != vDRID {
        newDRID = drID
      } else {
        newDRID = vDRID
      }
      
      state.flow = .visits(.assigned(Set(v.compactMap(eitherRight))), h, s, pk, newDRID, deID, us, p, .none, ps, .none)
  
      
      if let drID = drID, drID != vDRID {
        return .merge(
          .cancel(id: TimerID()),
          environment
            .hyperTrack
            .setDriverID(drID)
            .fireAndForget()
        )
      } else {
        return .cancel(id: TimerID())
      }
    case let (.selectedMixed(v, vs), vPK, vDRID, pk, drID, .some(.hideManualVisits)) where vPK == pk:
      let newDRID: DriverID
      if let drID = drID, drID != vDRID {
        newDRID = drID
      } else {
        newDRID = vDRID
      }
      
      let aas =  Set(vs.compactMap(eitherRight))
      if case let .right(a) = v {
        state.flow = .visits(.selectedAssigned(a, aas), h, s, pk, newDRID, deID, us, p, .none, ps, .none)
      } else {
        state.flow = .visits(.assigned(aas), h, s, pk, newDRID, deID, us, p, .none, ps, .none)
      }
      
      if let drID = drID, drID != vDRID {
        return .merge(
          .cancel(id: TimerID()),
          environment
            .hyperTrack
            .setDriverID(drID)
            .fireAndForget()
        )
      } else {
        return .cancel(id: TimerID())
      }
    case let (.assigned(v), vPK, vDRID, pk, drID, .some(.showManualVisits)) where vPK == pk:
      let newDRID: DriverID
      if let drID = drID, drID != vDRID {
        newDRID = drID
      } else {
        newDRID = vDRID
      }
      
      state.flow = .visits(.mixed(Set(v.map(Either.right))), h, s, pk, newDRID, deID, us, p, .none, ps, .none)
      
      if let drID = drID, drID != vDRID {
        return .merge(
          .cancel(id: TimerID()),
          environment
            .hyperTrack
            .setDriverID(drID)
            .fireAndForget()
        )
      } else {
        return .cancel(id: TimerID())
      }
    case let (.selectedAssigned(a, aas), vPK, vDRID, pk, drID, .some(.showManualVisits)) where vPK == pk:
      let newDRID: DriverID
      if let drID = drID, drID != vDRID {
        newDRID = drID
      } else {
        newDRID = vDRID
      }
      
      state.flow = .visits(.selectedMixed(.right(a), Set(aas.map(Either.right))), h, s, pk, newDRID, deID, us, p, .none, ps, .none)
      
      if let drID = drID, drID != vDRID {
        return .merge(
          .cancel(id: TimerID()),
          environment
            .hyperTrack
            .setDriverID(drID)
            .fireAndForget()
        )
      } else {
        return .cancel(id: TimerID())
      }
    case let (_, vPK, vDRID, pk, drID, mvs) where vPK != pk:
      let newDRID: DriverID
      if let drID = drID, drID != vDRID {
        newDRID = drID
      } else {
        newDRID = vDRID
      }
      
      let newV: Visits
      switch rMVS {
      case .showManualVisits:
        newV = .mixed([])
      case .hideManualVisits:
        newV = .assigned([])
      }
      
      state.flow = .visits(v, h, s, vPK, vDRID, deID, us, p, .none, ps, .waitingForSDKWith(pk, newDRID, rMVS))
      
      return .merge(
        .cancel(id: TimerID()),
        environment
          .hyperTrack
          .makeSDK(pk)
          .receive(on: environment.mainQueue())
          .eraseToEffect()
          .map(AppAction.madeSDK)
      )
    default: return .cancel(id: TimerID())
    }
  case (_, .stateRestored):
    return environment
      .deepLink
      .subscribeToDeepLinks()
      .receive(on: environment.mainQueue())
      .eraseToEffect()
      .map(AppAction.receivedDeepLink)
  case let (_, .deepLinkOpened(a)):
    return environment
      .deepLink
      .continueUserActivity(a)
      .fireAndForget()
  case (_, .deepLinkTimerFired):
    return .cancel(id: TimerID())
  default: return .none
  }
}

func toAssignedMaintainingSelection(_ v: NonEmptyArray<Visit>) -> Either<NonEmptyArray<AssignedVisit>, [AssignedVisit]> {
  let head = v.first
  let restAssigned = Array(v.dropFirst()).compactMap(eitherRight)
  switch head {
  case .left:
    return .right(restAssigned)
  case let .right(a):
    return .left(NonEmptyArray(rawValue: [a] + restAssigned)!)
  }
}
