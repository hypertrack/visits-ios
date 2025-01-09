import AppArchitecture
import Combine
import ComposableArchitecture
import StateRestorationEnvironment
import Types
import Utility


// MARK: - State

public enum StateRestorationState: Equatable {
  case waitingToStart
  case restoringState
  case stateRestored(RestoredState)
}

// MARK: - Action

public enum StateRestorationAction: Equatable {
  case osFinishedLaunching
  case restoredState(StorageState?, AppVersion, StateRestorationError?)
}

// MARK: - Environment

public struct StateRestorationLogicEnvironment {
  public var appVersion: () -> Effect<AppVersion, Never>
  public var loadState: () -> Effect<Result<StorageState?, StateRestorationError>, Never>
  
  public init(
    appVersion: @escaping () -> Effect<AppVersion, Never>,
    loadState: @escaping () -> Effect<Result<StorageState?, StateRestorationError>, Never>
  ) {
    self.appVersion = appVersion
    self.loadState = loadState
  }
}

// MARK: - Reducer

public let stateRestorationReducer: Reducer<
  StateRestorationState,
  StateRestorationAction,
  SystemEnvironment<StateRestorationLogicEnvironment>
> = Reducer { state, action, environment in
  switch action {
  case .osFinishedLaunching:
    guard state == .waitingToStart else { return .none }
    
    state = .restoringState
    
    return Publishers.Zip(
     environment.loadState(),
      environment.appVersion()
    )
    .map { (z: (result: Result<StorageState?, StateRestorationError>, version: AppVersion)) in
      .restoredState(resultSuccess(z.result) >>- identity, z.version, resultFailure(z.result))
    }
    .receive(on: environment.mainQueue)
    .eraseToEffect()
    
  case let .restoredState(ss, ver, _):
    guard state == .restoringState else { return .none }

    let restored: RestoredState
    switch ss {
    case .none:
      restored = RestoredState(
        experience: .firstRun,
        flow: .firstRun,
        locationAlways: .notRequested,
        pushStatus: .dialogSplash(.notShown),
        version: ver
      )
    case let .some(ss):
      let flow: RestoredState.Flow
      switch ss.flow {
        case .firstRun:
        flow = .firstRun
      case let .signIn(e):
          flow = .signIn(e)
      case let .main(t, p, n, w):
        let (fr, to) = environment.defaultVisitsDatePickerFromTo()
        flow = .main(t, p, n, w, fr, to)
      }
      restored = RestoredState(
        experience: ss.experience,
        flow: flow,
        locationAlways: ss.locationAlways,
        pushStatus: ss.pushStatus,
        version: ver
      )
    }
    state = .stateRestored(restored)

    return .none
  }
}

private extension StorageState {
  static let firstRun: Self = .init(
    experience: .firstRun,
    flow: .firstRun,
    locationAlways: .notRequested,
    pushStatus: .dialogSplash(.notShown)
  )
}
