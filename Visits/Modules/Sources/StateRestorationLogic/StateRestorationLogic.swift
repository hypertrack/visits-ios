import AppArchitecture
import Combine
import ComposableArchitecture
import NonEmpty
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
  public var getMetadata: () -> Effect<JSON.Object, Never>
  public var loadState: () -> Effect<Result<StorageState?, StateRestorationError>, Never>

  public init(
    appVersion: @escaping () -> Effect<AppVersion, Never>,
    getMetadata: @escaping () -> Effect<JSON.Object, Never>,
    loadState: @escaping () -> Effect<Result<StorageState?, StateRestorationError>, Never>
  ) {
    self.appVersion = appVersion
    self.getMetadata = getMetadata
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

    let loadStatePublisher: Effect<Result<StorageState?, StateRestorationError>, Never> = environment.loadState()
      .flatMap { (result: Result<StorageState?, StateRestorationError>) in
        switch result {
        case let .success(loadedState):
          if var loadedState = loadedState,
            case let .main(tabSelection, publishableKey, name, workerHandle) = loadedState.flow,
            workerHandle == nil
          {
            return environment.getMetadata()
              .map(restoreWorkerHandleFromMetadata)
              .map { restoredWorkerHandle in
                if let restoredWorkerHandle = restoredWorkerHandle {
                  loadedState.flow = .main(
                    tabSelection,
                    publishableKey,
                    name,
                    restoredWorkerHandle
                  )
                }
                return Result<StorageState?, StateRestorationError>.success(loadedState)
              }
          } else {
            return Just(.success(loadedState)).eraseToEffect()
          }
        case let .failure(error):
          return Just(.failure(error)).eraseToEffect()
        }
      }.eraseToEffect()

    return Publishers.Zip(
      loadStatePublisher,
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
      case let .main(t, p, n, workerHandle):
        let (fr, to) = environment.defaultVisitsDatePickerFromTo()
        if let workerHandle = workerHandle {
          flow = .main(t, p, n, workerHandle, fr, to)
        } else {
          flow = .signIn(nil)
        }
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

private func restoreWorkerHandleFromMetadata(_ metadata: JSON.Object) -> WorkerHandle? {
  let emailJson = metadata["email"]
  if case let .string(email) = emailJson {
    if !email.isEmpty {
      return WorkerHandle(email)
    }
  }
  let phoneJson = metadata["phone_number"]
  if case let .string(phone) = phoneJson {
    if !phone.isEmpty {
      return WorkerHandle(phone)
    }
  }
  return nil
}

private extension StorageState {
  static let firstRun: Self = .init(
    experience: .firstRun,
    flow: .firstRun,
    locationAlways: .notRequested,
    pushStatus: .dialogSplash(.notShown)
  )
}
