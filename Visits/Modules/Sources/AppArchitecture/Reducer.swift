import ComposableArchitecture
import LogEnvironment
import Utility

public func send<State, Action>(_ viewStore: ViewStore<State, Action>) -> (Action) -> Void {
  { a in viewStore.send(a) }
}

public extension Reducer {  
  func pullback<GlobalState, GlobalAction, GlobalEnvironment>(
    state localStateAffine: Affine<GlobalState, State>,
    action localActionPrism: Prism<GlobalAction, Action>,
    environment toLocalEnvironment: @escaping (GlobalEnvironment) -> Environment
  ) -> Reducer<GlobalState, GlobalAction, GlobalEnvironment> {
    .init { gs, ga, ge in
      guard var ls = localStateAffine.extract(from: gs),
            let la = localActionPrism.extract(from: ga)
      else { return .none }
      let e = self.run(&ls, la, toLocalEnvironment(ge))
        .map(localActionPrism.embed)
      
      // Affine laws guarantee injection after successful extraction
      gs = (gs |> localStateAffine.inject(ls))!
      return e
    }
  }
  
  func onEntry<LocalState>(
    _ toLocalState: @escaping (State) -> LocalState?,
    send toEffect: @escaping (LocalState, Environment) -> Effect<Action, Never>
  ) -> Self where LocalState: Equatable {
    .init { state, action, environment in
      let previousLocalState = toLocalState(state)
      let effects = self.run(&state, action, environment)
      let nextLocalState = toLocalState(state)
      
      if let localState = nextLocalState, previousLocalState == nil {
        return .merge(effects, toEffect(localState, environment))
      } else {
        return effects
      }
    }
  }
  
  func onExit<LocalState>(
    _ toLocalState: @escaping (State) -> LocalState?,
    send toEffect: @escaping (LocalState) -> Effect<Action, Never>
  ) -> Self where LocalState: Equatable {
    .init { state, action, environment in
      let previousLocalState = toLocalState(state)
      let effects = self.run(&state, action, environment)
      let nextLocalState = toLocalState(state)
      
      if let localState = previousLocalState, nextLocalState == nil {
        return .merge(effects, toEffect(localState))
      } else {
        return effects
      }
    }
  }
  
  func onChange<LocalState>(
    _ toLocalState: @escaping (State) -> LocalState?,
    send toEffect: @escaping (LocalState) -> Effect<Action, Never>
  ) -> Self where LocalState: Equatable {
    .init { state, action, environment in
      let previousLocalState = toLocalState(state)
      let effects = self.run(&state, action, environment)
      let nextLocalState = toLocalState(state)
      
      if let previousLocalState = previousLocalState,
         let nextLocalState = nextLocalState,
         previousLocalState != nextLocalState {
        return .merge(effects, toEffect(nextLocalState))
      } else {
        return effects
      }
    }
  }
  
  func onChange<LocalState>(
    _ toLocalState: @escaping (State) -> LocalState?,
    send toEffect: @escaping (LocalState, LocalState) -> Effect<Action, Never>
  ) -> Self where LocalState: Equatable {
    .init { state, action, environment in
      let previousLocalState = toLocalState(state)
      let effects = self.run(&state, action, environment)
      let nextLocalState = toLocalState(state)
      
      if let previousLocalState = previousLocalState,
         let nextLocalState = nextLocalState,
         previousLocalState != nextLocalState {
        return .merge(effects, toEffect(previousLocalState, nextLocalState))
      } else {
        return effects
      }
    }
  }
}

public extension Reducer {
  func prettyDebug() -> Reducer {
    self.debug() { _ in
      DebugEnvironment(
        printer: {
          logAction($0)
        }
      )
    }
  }
}

public extension Reducer where Action: Equatable {
  static func toggleReducer(
    _ ls: State,
    _ la: Action,
    _ rs: State,
    _ ra: Action
  ) -> Reducer {
    .init { state, action, _ in
      switch action {
      case la: state = ls
      case ra: state = rs
      default: return .none
      }
      return .none
    }
  }
}
