import AppArchitecture
import ComposableArchitecture
import RestorationState

extension Reducer where State == AppState, Action == AppAction, Environment == SystemEnvironment<AppEnvironment> {
  func autosave() -> Reducer {
    .init { state, action, environment in
      let previousState = state
      let effects = self.run(&state, action, environment)
      let nextState = state
      
      switch nextState.flow {
      case .created,
           .appLaunching:
        return effects
      default:
        
        let previousSave = saveFlow(previousState.flow)
        let nextSave = saveFlow(nextState.flow)
        if previousSave == nextSave {
          return effects
        } else {
          return .merge(
            environment
              .stateRestoration
              .saveState(nextSave)
              .fireAndForget(),
            effects
          )
        }
      }
    }
  }
}

func saveFlow(_ appFlow: AppFlow) -> StorageState? {
  switch appFlow {
  case .created,
       .appLaunching,
       .noMotionServices:
    return nil
  case let .signIn(.editingCredentials(.some(.this(e)), _)):
    return .signIn(e)
  case let .signIn(.editingCredentials(.some(.both(e, _)), _)):
    return .signIn(e)
  case .signIn:
    return nil
  case let .driverID(drID, pk, mvs, _):
    return .driverID(drID, pk, mvs)
  case let .visits(v, _, s, pk, drID, _, _, _, _, ps, e, _):
    return .visits(v, s, pk, drID, ps, e)
  }
}
