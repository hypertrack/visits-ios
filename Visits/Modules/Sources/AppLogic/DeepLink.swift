import AppArchitecture
import ComposableArchitecture
import NonEmpty
import Prelude
import Tagged
import Types


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
  case let (.driverID(_, _, .waitingForSDKWith(pk, drID)), .madeSDK(s, p)),
       let (.signIn(.editingCredentials(_, .right(.waitingForSDKWith(pk, drID)))), .madeSDK(s, p)),
       let (.signUp(.formFilled(_, _, _, _, _, .waitingForSDKWith(pk, drID))), .madeSDK(s, p)),
       let (.signUp(.formFilling(_, _, _, _, _, .waitingForSDKWith(pk, drID))), .madeSDK(s, p)),
       let (.signUp(.questions(_, _, _, .answering(_, _, .waitingForSDKWith(pk, drID)))), .madeSDK(s, p)),
       let (.signUp(.verification(.entered(_, .notSent(_, _, .waitingForSDKWith(pk, drID))), _, _)), .madeSDK(s, p)),
       let (.signUp(.verification(.entering(_, _, _, .waitingForSDKWith(pk, drID)), _, _)), .madeSDK(s, p)):
    switch s {
    case .locked:
      state.flow = .noMotionServices
      return .none
    case let .unlocked(deID, s):
      state.flow = .visits([], nil, nil, .defaultTab, pk, drID, deID, s, p, .none, .dialogSplash(.notShown), .firstRun, .none)
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
  case let (.visits(_, _, _, _, _, _, _, _, _, _, ps, e, .waitingForSDKWith(pk, drID)), .madeSDK(s, p)):
    switch s {
    case .locked:
      state.flow = .noMotionServices
      return .none
    case let .unlocked(deID, s):
      state.flow = .visits([], nil, nil, .defaultTab, pk, drID, deID, s, p, .none, ps, e, .none)
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
  case let (.driverID(drID, pk, .none), .deepLinkOpened(a)):
    state.flow = .driverID(drID, pk, .waitingForDeepLink)
    return setTimerAndProcessDeeplink(a)
  case let (.driverID(drID, pk, .none), .receivedDeepLink(dPK, dDRIDD)):
    state.flow = .driverID(drID, pk, .waitingForTimerWith(dPK, dDRIDD))
    return timer
  case let (.driverID(drID, pk, .waitingForDeepLink), .deepLinkTimerFired):
    state.flow = .driverID(drID, pk, .none)
    return .cancel(id: TimerID())
  case let (.driverID(drID, pk, .waitingForDeepLink), .receivedDeepLink(dPK, dDRIDD)):
    state.flow = .driverID(drID, pk, .waitingForTimerWith(dPK, dDRIDD))
    return .none
  case let (.driverID(drID, pk, .waitingForTimerWith(dPK, dDRIDD)), .deepLinkTimerFired):
    if let dDRIDD = dDRIDD {
      state.flow = .driverID(dDRIDD, dPK, .waitingForSDKWith(dPK, dDRIDD))
      return stopTimerAndInitSDK(pk)
    } else {
      state.flow = .driverID(drID, dPK, .none)
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
  case let (.signUp(.formFilled(n, e, p, f, er, .none)), .receivedDeepLink(pk, drID)):
    state.flow = .signUp(.formFilled(n, e, p, f, er, .waitingForTimerWith(pk, drID)))
    return timer
  case let (.signUp(.formFilling(n, e, p, f, er, .none)), .receivedDeepLink(pk, drID)):
    state.flow = .signUp(.formFilling(n, e, p, f, er, .waitingForTimerWith(pk, drID)))
    return timer
  case let (.signUp(.questions(n, e, p, .answering(ebm, efe, .none))), .receivedDeepLink(pk, drID)):
    state.flow = .signUp(.questions(n, e, p, .answering(ebm, efe, .waitingForTimerWith(pk, drID))))
    return timer
  case let (.signUp(.verification(.entered(c, .notSent(f, er, .none)), e, p)), .receivedDeepLink(pk, drID)):
    state.flow = .signUp(.verification(.entered(c, .notSent(f, er, .waitingForTimerWith(pk, drID))), e, p))
    return timer
  case let (.signUp(.verification(.entering(c, f, er, .none), e, p)), .receivedDeepLink(pk, drID)):
    state.flow = .signUp(.verification(.entering(c, f, er, .waitingForTimerWith(pk, drID)), e, p))
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
    
  case let (.signUp(.formFilled(n, e, p, f, er, .waitingForDeepLink)), .receivedDeepLink(pk, drID)):
    state.flow = .signUp(.formFilled(n, e, p, f, er, .waitingForTimerWith(pk, drID)))
    return .none
  case let (.signUp(.formFilling(n, e, p, f, er, .waitingForDeepLink)), .receivedDeepLink(pk, drID)):
    state.flow = .signUp(.formFilling(n, e, p, f, er, .waitingForTimerWith(pk, drID)))
    return .none
  case let (.signUp(.questions(n, e, p, .answering(ebm, efe, .waitingForDeepLink))), .receivedDeepLink(pk, drID)):
    state.flow = .signUp(.questions(n, e, p, .answering(ebm, efe, .waitingForTimerWith(pk, drID))))
    return .none
  case let (.signUp(.verification(.entered(c, .notSent(f, er, .waitingForDeepLink)), e, p)), .receivedDeepLink(pk, drID)):
    state.flow = .signUp(.verification(.entered(c, .notSent(f, er, .waitingForTimerWith(pk, drID))), e, p))
    return .none
  case let (.signUp(.verification(.entering(c, f, er, .waitingForDeepLink), e, p)), .receivedDeepLink(pk, drID)):
    state.flow = .signUp(.verification(.entering(c, f, er, .waitingForTimerWith(pk, drID)), e, p))
    return .none
    
  case let (.signUp(.formFilled(n, e, p, f, er, .waitingForTimerWith(pk, drID))), .deepLinkTimerFired):
    if let drID = drID {
      state.flow = .signUp(.formFilled(n, e, p, f, er, .waitingForSDKWith(pk, drID)))
      return stopTimerAndInitSDK(pk)
    } else {
      state.flow = .driverID(nil, pk, nil)
      return .cancel(id: TimerID())
    }
  case let (.signUp(.formFilling(n, e, p, f, er, .waitingForTimerWith(pk, drID))), .deepLinkTimerFired):
    if let drID = drID {
      state.flow = .signUp(.formFilling(n, e, p, f, er, .waitingForSDKWith(pk, drID)))
      return stopTimerAndInitSDK(pk)
    } else {
      state.flow = .driverID(nil, pk, nil)
      return .cancel(id: TimerID())
    }
  case let (.signUp(.questions(n, e, p, .answering(ebm, efe, .waitingForTimerWith(pk, drID)))), .deepLinkTimerFired):
    if let drID = drID {
      state.flow = .signUp(.questions(n, e, p, .answering(ebm, efe, .waitingForSDKWith(pk, drID))))
      return stopTimerAndInitSDK(pk)
    } else {
      state.flow = .driverID(nil, pk, nil)
      return .cancel(id: TimerID())
    }
  case let (.signUp(.verification(.entered(c, .notSent(f, er, .waitingForTimerWith(pk, drID))), e, p)), .deepLinkTimerFired):
    if let drID = drID {
      state.flow = .signUp(.verification(.entered(c, .notSent(f, er, .waitingForSDKWith(pk, drID))), e, p))
      return stopTimerAndInitSDK(pk)
    } else {
      state.flow = .driverID(nil, pk, nil)
      return .cancel(id: TimerID())
    }
  case let (.signUp(.verification(.entering(c, f, er, .waitingForTimerWith(pk, drID)), e, p)), .deepLinkTimerFired):
    if let drID = drID {
      state.flow = .signUp(.verification(.entering(c, f, er, .waitingForSDKWith(pk, drID)), e, p))
      return stopTimerAndInitSDK(pk)
    } else {
      state.flow = .driverID(nil, pk, nil)
      return .cancel(id: TimerID())
    }
  
  case let (.signIn(.editingCredentials(tep, .none)), .deepLinkOpened(a)),
       let (.signIn(.editingCredentials(tep, .left)), .deepLinkOpened(a)):
    state.flow = .signIn(.editingCredentials(tep, .right(.waitingForDeepLink)))
    return setTimerAndProcessDeeplink(a)
  case let (.signIn(.editingCredentials(tep, .none)), .receivedDeepLink(pk, drID)),
       let (.signIn(.editingCredentials(tep, .left)), .receivedDeepLink(pk, drID)):
    state.flow = .signIn(.editingCredentials(tep, .right(.waitingForTimerWith(pk, drID))))
    return timer
  case let (.signIn(.editingCredentials(tep, .right(.waitingForDeepLink))), .deepLinkTimerFired):
    state.flow = .signIn(.editingCredentials(tep, .none))
    return .cancel(id: TimerID())
  case let (.signIn(.editingCredentials(tep, .right(.waitingForDeepLink))), .receivedDeepLink(pk, drID)):
    state.flow = .signIn(.editingCredentials(tep, .right(.waitingForTimerWith(pk, drID))))
    return .none
  case let (.signIn(.editingCredentials(tep, .right(.waitingForTimerWith(pk, drID)))), .deepLinkTimerFired):
    if let drID = drID {
      state.flow = .signIn(.editingCredentials(tep, .right(.waitingForSDKWith(pk, drID))))
      return stopTimerAndInitSDK(pk)
    } else {
      state.flow = .driverID(nil, pk, nil)
      return .cancel(id: TimerID())
    }
  case let (.visits(v, sv, h, s, vPK, vDRID, deID, us, p, _, ps, e, .none), .deepLinkOpened(a)):
    state.flow = .visits(v, sv, h, s, vPK, vDRID, deID, us, p, .none, ps, e, .waitingForDeepLink)
    return setTimerAndProcessDeeplink(a)
  case let (.visits(v, sv, h, s, vPK, vDRID, deID, us, p, _, ps, e, .none), .receivedDeepLink(pk, drID)):
    state.flow = .visits(v, sv, h, s, vPK, vDRID, deID, us, p, .none, ps, e, .waitingForTimerWith(pk, drID))
    return timer
  case let (.visits(v, sv, h, s, vPK, vDRID, deID, us, p, _, ps, e, .waitingForDeepLink), .receivedDeepLink(pk, drID)):
    state.flow = .visits(v, sv, h, s, vPK, vDRID, deID, us, p, .none, ps, e, .waitingForTimerWith(pk, drID))
    return .none
  case let (.visits(v, sv, h, s, vPK, vDRID, deID, us, p, _, ps, e, .waitingForDeepLink), .deepLinkTimerFired):
    state.flow = .visits(v, sv, h, s, vPK, vDRID, deID, us, p, .none, ps, e, .none)
    return .cancel(id: TimerID())
  case let (.visits(v, sv, h, s, vPK, vDRID, deID, us, p, _, ps, e, .waitingForTimerWith(pk, drID)), .deepLinkTimerFired):
    
    state.flow = .visits([], nil, h, s, vPK, vDRID, deID, us, p, .none, ps, e, .none)
    
    
    
    switch (v, vPK, vDRID, pk, drID) {
    case let (_, vPK, _, pk, .none) where vPK == pk:
      return .cancel(id: TimerID())
    case let (_, vPK, vDRID, pk, .some(drID)) where vPK == pk && vDRID == drID:
      return .cancel(id: TimerID())
    case let (_, vPK, vDRID, pk, .some(drID)) where vPK == pk && vDRID != drID:
      state.flow = .visits(v, sv, h, s, pk, drID, deID, us, p, .none, ps, e, .none)
      return cancelTimerAndSetDriverID(drID)
    case let (_, vPK, vDRID, pk, drID) where vPK != pk:
      let newDRID: DriverID
      if let drID = drID, drID != vDRID {
        newDRID = drID
      } else {
        newDRID = vDRID
      }
      
      state.flow = .visits([], nil, h, s, vPK, vDRID, deID, us, p, .none, ps, e, .waitingForSDKWith(pk, newDRID))
      
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
