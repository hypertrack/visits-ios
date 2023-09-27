import AppArchitecture
import ComposableArchitecture
import FirstRunLogic
import Utility
import Types


let firstRunP: Reducer<
  AppState,
  AppAction,
  SystemEnvironment<AppEnvironment>
> = firstRunReducer.pullback(
  state: firstRunStateAffine,
  action: firstRunActionPrism,
  environment: constant(())
)

func firstRunReadyState(_ a: AppState) -> Terminal? {
  a *^? /AppState.operational >>- _firstRunReadyState
}


private func _firstRunReadyState(_ o: OperationalState) -> Terminal? {
  guard o.isFirstRunState, o.experience == .firstRun else { return nil }
  
  return unit
}

private let firstRunStateAffine = /AppState.operational ** firstRunOperationalStateAffine

private let firstRunActionPrism = Prism<AppAction, FirstRunAction>(
  extract: { a in
    switch a {
    case .generated(.entered(.firstRunReadyToStart)): return .readyToStart
    case .startTracking:                              return .startTracking
    default:                                          return nil
    }
  },
  embed: { a in
    switch a {
    case .readyToStart:  return .generated(.entered(.firstRunReadyToStart))
    case .startTracking: return .startTracking
    }
  }
)

private let firstRunOperationalStateAffine = Affine<OperationalState, Experience>(
  extract: { d in
    guard d.isFirstRunState else { return nil }
    
    return d.experience
  },
  inject: { s in
    { d in
      guard d.isFirstRunState else { return nil }
      
      return d |> \.experience *< s
    }
  }
)

private extension OperationalState {
  var isFirstRunState: Bool {
    switch (self.flow, self.sdk.status, self.pushStatus) {
    case (.main, .unlocked(_, .stopped), .dialogSplash(.shown)):
      return true
    default:
      return false
    }
  }
}

