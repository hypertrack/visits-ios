import ComposableArchitecture
import StateRestorationEnvironment
import Types


// MARK: - State

public enum StateRestorationState: Equatable {
  case waitingToStart
  case restoringState
  case stateRestored(StorageState)
}

// MARK: - Action

public enum StateRestorationAction: Equatable {
  case osFinishedLaunching
  case restoredState(Result<StorageState?, StateRestorationError>)
}

// MARK: - Environment

public struct StateRestorationLogicEnvironment {
  public var loadState: () -> Effect<Result<StorageState?, StateRestorationError>, Never>
  
  public init(loadState: @escaping () -> Effect<Result<StorageState?, StateRestorationError>, Never>) {
    self.loadState = loadState
  }
}

// MARK: - Reducer

public let stateRestorationReducer: Reducer<
  StateRestorationState,
  StateRestorationAction,
  StateRestorationLogicEnvironment
> = Reducer { state, action, environment in
  switch action {
  case .osFinishedLaunching:
    guard state == .waitingToStart else { return .none }
    
    state = .restoringState
    
    return environment.loadState()
      .map(StateRestorationAction.restoredState)
      .eraseToEffect()
  case let .restoredState(result):
    guard state == .restoringState else { return .none }
    
    state = .stateRestored((try? result.get()) ?? .firstRun)
    
    return .none
  }
}

extension StorageState {
  static let firstRun: Self = .init(
    experience: .firstRun,
    flow: .firstRun,
    locationAlways: .notRequested,
    pushStatus: .dialogSplash(.notShown)
  )
}
