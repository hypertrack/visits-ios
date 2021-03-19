import AppArchitecture
import ComposableArchitecture
import PublishableKey
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
  
  func stopTimerAndInitSDK(_ pk: PublishableKey) -> Effect<AppAction, Never> {
    .merge(
      .cancel(id: TimerID()),
      environment.hyperTrack
        .makeSDK(pk)
        .receive(on: environment.mainQueue())
        .eraseToEffect()
        .map(AppAction.madeSDK)
    )
  }
  
  func setTimerAndProcessDeeplink(_ a: NSUserActivity) -> Effect<AppAction, Never> {
    .merge(
      timer,
      environment
        .deepLink
        .continueUserActivity(a)
        .fireAndForget()
    )
  }
  
  func cancelTimerAndSetDriverID(_ drID: DriverID) -> Effect<AppAction, Never> {
    .merge(
      .cancel(id: TimerID()),
      environment
        .hyperTrack
        .setDriverID(drID)
        .fireAndForget()
    )
  }
  
  switch (state.flow, action) {
  case (.appLaunching, .restoredState(.left(.deepLink), _)):
    return timer
  case let (.driverID(_, _, _, .waitingForSDKWith(pk, drID, mvs)), .madeSDK(s, p)),
       let (.signIn(.editingCredentials(_, .right(.waitingForSDKWith(pk, drID, mvs)))), .madeSDK(s, p)),
       let (.signUp(.formFilled(_, _, _, _, _, .waitingForSDKWith(pk, drID, mvs))), .madeSDK(s, p)),
       let (.signUp(.formFilling(_, _, _, _, _, .waitingForSDKWith(pk, drID, mvs))), .madeSDK(s, p)),
       let (.signUp(.questions(_, _, _, .answering(_, _, .waitingForSDKWith(pk, drID, mvs)))), .madeSDK(s, p)),
       let (.signUp(.verification(.entered(_, .notSent(_, _, .waitingForSDKWith(pk, drID, mvs))), _, _)), .madeSDK(s, p)),
       let (.signUp(.verification(.entering(_, _, _, .waitingForSDKWith(pk, drID, mvs)), _, _)), .madeSDK(s, p)):
    switch s {
    case .locked:
      state.flow = .noMotionServices
      return .none
    case let .unlocked(deID, s):
      switch mvs {
      case .none,
           .some(.hideManualVisits):
        state.flow = .visits(.default, nil, .defaultTab, pk, drID, deID, s, p, nil, .dialogSplash(.notShown), .firstRun, .none)
      case .some(.showManualVisits):
        state.flow = .visits(.mixed([]), nil, .defaultTab, pk, drID, deID, s, p, nil, .dialogSplash(.notShown), .firstRun, .none)
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
  case let (.visits(_, _, _, _, _, _, _, _, _, ps, e, .waitingForSDKWith(pk, drID, mvs)), .madeSDK(s, p)):
    switch s {
    case .locked:
      state.flow = .noMotionServices
      return .none
    case let .unlocked(deID, s):
      switch mvs {
      case .none,
           .some(.hideManualVisits):
        state.flow = .visits(.default, nil, .defaultTab, pk, drID, deID, s, p, nil, ps, e, .none)
      case .some(.showManualVisits):
        state.flow = .visits(.mixed([]), nil, .defaultTab, pk, drID, deID, s, p, nil, ps, e, .none)
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
    return setTimerAndProcessDeeplink(a)
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
      return stopTimerAndInitSDK(pk)
    } else {
      state.flow = .driverID(drID, dPK, newMVS, .none)
      return .cancel(id: TimerID())
    }
  case let (.signUp(.formFilled(n, e, p, f, er, .none)), .deepLinkOpened(a)):
    state.flow = .signUp(.formFilled(n, e, p, f, er, .waitingForDeepLink))
    return setTimerAndProcessDeeplink(a)
  case let (.signUp(.formFilling(n, e, p, f, er, .none)), .deepLinkOpened(a)):
    state.flow = .signUp(.formFilling(n, e, p, f, er, .waitingForDeepLink))
    return setTimerAndProcessDeeplink(a)
  case let (.signUp(.questions(n, e, p, .answering(ebm, efe, .none))), .deepLinkOpened(a)):
    state.flow = .signUp(.questions(n, e, p, .answering(ebm, efe, .waitingForDeepLink)))
    return setTimerAndProcessDeeplink(a)
  case let (.signUp(.verification(.entered(c, .notSent(f, er, .none)), e, p)), .deepLinkOpened(a)):
    state.flow = .signUp(.verification(.entered(c, .notSent(f, er, .waitingForDeepLink)), e, p))
    return setTimerAndProcessDeeplink(a)
  case let (.signUp(.verification(.entering(c, f, er, .none), e, p)), .deepLinkOpened(a)):
    state.flow = .signUp(.verification(.entering(c, f, er, .waitingForDeepLink), e, p))
    return setTimerAndProcessDeeplink(a)
  case let (.signUp(.formFilled(n, e, p, f, er, .none)), .receivedDeepLink(pk, drID, mvs)):
    state.flow = .signUp(.formFilled(n, e, p, f, er, .waitingForTimerWith(pk, drID, mvs)))
    return timer
  case let (.signUp(.formFilling(n, e, p, f, er, .none)), .receivedDeepLink(pk, drID, mvs)):
    state.flow = .signUp(.formFilling(n, e, p, f, er, .waitingForTimerWith(pk, drID, mvs)))
    return timer
  case let (.signUp(.questions(n, e, p, .answering(ebm, efe, .none))), .receivedDeepLink(pk, drID, mvs)):
    state.flow = .signUp(.questions(n, e, p, .answering(ebm, efe, .waitingForTimerWith(pk, drID, mvs))))
    return timer
  case let (.signUp(.verification(.entered(c, .notSent(f, er, .none)), e, p)), .receivedDeepLink(pk, drID, mvs)):
    state.flow = .signUp(.verification(.entered(c, .notSent(f, er, .waitingForTimerWith(pk, drID, mvs))), e, p))
    return timer
  case let (.signUp(.verification(.entering(c, f, er, .none), e, p)), .receivedDeepLink(pk, drID, mvs)):
    state.flow = .signUp(.verification(.entering(c, f, er, .waitingForTimerWith(pk, drID, mvs)), e, p))
    return timer
  case let (.signUp(.formFilled(n, e, p, f, er, .waitingForDeepLink)), .deepLinkTimerFired):
    state.flow = .signUp(.formFilled(n, e, p, f, er, .none))
    return .cancel(id: TimerID())
  case let (.signUp(.formFilling(n, e, p, f, er, .waitingForDeepLink)), .deepLinkTimerFired):
    state.flow = .signUp(.formFilling(n, e, p, f, er, .none))
    return .cancel(id: TimerID())
  case let (.signUp(.questions(n, e, p, .answering(ebm, efe, .waitingForDeepLink))), .deepLinkTimerFired):
    state.flow = .signUp(.questions(n, e, p, .answering(ebm, efe, .none)))
    return .cancel(id: TimerID())
  case let (.signUp(.verification(.entered(c, .notSent(f, er, .waitingForDeepLink)), e, p)), .deepLinkTimerFired):
    state.flow = .signUp(.verification(.entered(c, .notSent(f, er, .none)), e, p))
    return .cancel(id: TimerID())
  case let (.signUp(.verification(.entering(c, f, er, .waitingForDeepLink), e, p)), .deepLinkTimerFired):
    state.flow = .signUp(.verification(.entering(c, f, er, .none), e, p))
    return .cancel(id: TimerID())
    
  case let (.signUp(.formFilled(n, e, p, f, er, .waitingForDeepLink)), .receivedDeepLink(pk, drID, mvs)):
    state.flow = .signUp(.formFilled(n, e, p, f, er, .waitingForTimerWith(pk, drID, mvs)))
    return .none
  case let (.signUp(.formFilling(n, e, p, f, er, .waitingForDeepLink)), .receivedDeepLink(pk, drID, mvs)):
    state.flow = .signUp(.formFilling(n, e, p, f, er, .waitingForTimerWith(pk, drID, mvs)))
    return .none
  case let (.signUp(.questions(n, e, p, .answering(ebm, efe, .waitingForDeepLink))), .receivedDeepLink(pk, drID, mvs)):
    state.flow = .signUp(.questions(n, e, p, .answering(ebm, efe, .waitingForTimerWith(pk, drID, mvs))))
    return .none
  case let (.signUp(.verification(.entered(c, .notSent(f, er, .waitingForDeepLink)), e, p)), .receivedDeepLink(pk, drID, mvs)):
    state.flow = .signUp(.verification(.entered(c, .notSent(f, er, .waitingForTimerWith(pk, drID, mvs))), e, p))
    return .none
  case let (.signUp(.verification(.entering(c, f, er, .waitingForDeepLink), e, p)), .receivedDeepLink(pk, drID, mvs)):
    state.flow = .signUp(.verification(.entering(c, f, er, .waitingForTimerWith(pk, drID, mvs)), e, p))
    return .none
    
  case let (.signUp(.formFilled(n, e, p, f, er, .waitingForTimerWith(pk, drID, mvs))), .deepLinkTimerFired):
    if let drID = drID {
      state.flow = .signUp(.formFilled(n, e, p, f, er, .waitingForSDKWith(pk, drID, mvs)))
      return stopTimerAndInitSDK(pk)
    } else {
      state.flow = .driverID(nil, pk, mvs, nil)
      return .cancel(id: TimerID())
    }
  case let (.signUp(.formFilling(n, e, p, f, er, .waitingForTimerWith(pk, drID, mvs))), .deepLinkTimerFired):
    if let drID = drID {
      state.flow = .signUp(.formFilling(n, e, p, f, er, .waitingForSDKWith(pk, drID, mvs)))
      return stopTimerAndInitSDK(pk)
    } else {
      state.flow = .driverID(nil, pk, mvs, nil)
      return .cancel(id: TimerID())
    }
  case let (.signUp(.questions(n, e, p, .answering(ebm, efe, .waitingForTimerWith(pk, drID, mvs)))), .deepLinkTimerFired):
    if let drID = drID {
      state.flow = .signUp(.questions(n, e, p, .answering(ebm, efe, .waitingForSDKWith(pk, drID, mvs))))
      return stopTimerAndInitSDK(pk)
    } else {
      state.flow = .driverID(nil, pk, mvs, nil)
      return .cancel(id: TimerID())
    }
  case let (.signUp(.verification(.entered(c, .notSent(f, er, .waitingForTimerWith(pk, drID, mvs))), e, p)), .deepLinkTimerFired):
    if let drID = drID {
      state.flow = .signUp(.verification(.entered(c, .notSent(f, er, .waitingForSDKWith(pk, drID, mvs))), e, p))
      return stopTimerAndInitSDK(pk)
    } else {
      state.flow = .driverID(nil, pk, mvs, nil)
      return .cancel(id: TimerID())
    }
  case let (.signUp(.verification(.entering(c, f, er, .waitingForTimerWith(pk, drID, mvs)), e, p)), .deepLinkTimerFired):
    if let drID = drID {
      state.flow = .signUp(.verification(.entering(c, f, er, .waitingForSDKWith(pk, drID, mvs)), e, p))
      return stopTimerAndInitSDK(pk)
    } else {
      state.flow = .driverID(nil, pk, mvs, nil)
      return .cancel(id: TimerID())
    }
  
  case let (.signIn(.editingCredentials(tep, .none)), .deepLinkOpened(a)),
       let (.signIn(.editingCredentials(tep, .left)), .deepLinkOpened(a)):
    state.flow = .signIn(.editingCredentials(tep, .right(.waitingForDeepLink)))
    return setTimerAndProcessDeeplink(a)
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
      return stopTimerAndInitSDK(pk)
    } else {
      state.flow = .driverID(nil, pk, mvs, nil)
      return .cancel(id: TimerID())
    }
  case let (.visits(v, h, s, vPK, vDRID, deID, us, p, _, ps, e, .none), .deepLinkOpened(a)):
    state.flow = .visits(v, h, s, vPK, vDRID, deID, us, p, .none, ps, e, .waitingForDeepLink)
    return setTimerAndProcessDeeplink(a)
  case let (.visits(v, h, s, vPK, vDRID, deID, us, p, _, ps, e, .none), .receivedDeepLink(pk, drID, mvs)):
    state.flow = .visits(v, h, s, vPK, vDRID, deID, us, p, .none, ps, e, .waitingForTimerWith(pk, drID, mvs))
    return timer
  case let (.visits(v, h, s, vPK, vDRID, deID, us, p, _, ps, e, .waitingForDeepLink), .receivedDeepLink(pk, drID, mvs)):
    state.flow = .visits(v, h, s, vPK, vDRID, deID, us, p, .none, ps, e, .waitingForTimerWith(pk, drID, mvs))
    return .none
  case let (.visits(v, h, s, vPK, vDRID, deID, us, p, _, ps, e, .waitingForDeepLink), .deepLinkTimerFired):
    state.flow = .visits(v, h, s, vPK, vDRID, deID, us, p, .none, ps, e, .none)
    return .cancel(id: TimerID())
  case let (.visits(v, h, s, vPK, vDRID, deID, us, p, _, ps, e, .waitingForTimerWith(pk, drID, mvs)), .deepLinkTimerFired):
    
    let vMVS: ManualVisitsStatus
    switch v {
    case .mixed,
         .selectedMixed:
      vMVS = .showManualVisits
    default:
      vMVS = .hideManualVisits
    }
    let rMVS = mvs ?? vMVS
    
    state.flow = .visits(v, h, s, vPK, vDRID, deID, us, p, .none, ps, e, .none)
    
    switch (v, vPK, vDRID, pk, drID, mvs) {
    case let (_, vPK, _, pk, .none, .none) where vPK == pk:
      return .cancel(id: TimerID())
    case let (_, vPK, vDRID, pk, .some(drID), .none) where vPK == pk && vDRID == drID:
      return .cancel(id: TimerID())
    case let (_, vPK, vDRID, pk, .some(drID), .none) where vPK == pk && vDRID != drID:
      state.flow = .visits(v, h, s, pk, drID, deID, us, p, .none, ps, e, .none)
      return cancelTimerAndSetDriverID(drID)
    case let (.mixed, vPK, vDRID, pk, drID, .some(.showManualVisits)) where vPK == pk,
         let (.selectedMixed, vPK, vDRID, pk, drID, .some(.showManualVisits)) where vPK == pk,
         let (.assigned, vPK, vDRID, pk, drID, .some(.hideManualVisits)) where vPK == pk,
         let (.selectedAssigned, vPK, vDRID, pk,drID, .some(.hideManualVisits)) where vPK == pk:
      if let drID = drID, drID != vDRID {
        state.flow = .visits(v, h, s, pk, drID, deID, us, p, .none, ps, e, .none)
        return cancelTimerAndSetDriverID(drID)
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
      
      state.flow = .visits(.assigned(Set(v.compactMap(eitherRight))), h, s, pk, newDRID, deID, us, p, .none, ps, e, .none)
  
      
      if let drID = drID, drID != vDRID {
        return cancelTimerAndSetDriverID(drID)
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
        state.flow = .visits(.selectedAssigned(a, aas), h, s, pk, newDRID, deID, us, p, .none, ps, e, .none)
      } else {
        state.flow = .visits(.assigned(aas), h, s, pk, newDRID, deID, us, p, .none, ps, e, .none)
      }
      
      if let drID = drID, drID != vDRID {
        return cancelTimerAndSetDriverID(drID)      } else {
        return .cancel(id: TimerID())
      }
    case let (.assigned(v), vPK, vDRID, pk, drID, .some(.showManualVisits)) where vPK == pk:
      let newDRID: DriverID
      if let drID = drID, drID != vDRID {
        newDRID = drID
      } else {
        newDRID = vDRID
      }
      
      state.flow = .visits(.mixed(Set(v.map(Either.right))), h, s, pk, newDRID, deID, us, p, .none, ps, e, .none)
      
      if let drID = drID, drID != vDRID {
        return cancelTimerAndSetDriverID(drID)
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
      
      state.flow = .visits(.selectedMixed(.right(a), Set(aas.map(Either.right))), h, s, pk, newDRID, deID, us, p, .none, ps, e, .none)
      
      if let drID = drID, drID != vDRID {
        return cancelTimerAndSetDriverID(drID)
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
      
      state.flow = .visits(v, h, s, vPK, vDRID, deID, us, p, .none, ps, e, .waitingForSDKWith(pk, newDRID, rMVS))
      
      return stopTimerAndInitSDK(pk)
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
