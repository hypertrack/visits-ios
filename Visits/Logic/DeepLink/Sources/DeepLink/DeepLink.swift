import ComposableArchitecture
import DeepLinkEnvironment
import DriverID
import ManualVisitsStatus
import NetworkEnvironment
import Prelude
import PublishableKey
import RestorationState
import SDK

// MARK: - Action

public enum DeepLinkAction {
  // Processes
  case deepLinkOpened(NSUserActivity)
  // Emits
  case deepLinkTimerFired
  // Processes
  case finishedLaunching
  // Emits
  case receivedDeepLink(PublishableKey, DriverID?, ManualVisitsStatus?)
  // Processes
  case restoredState(Either<RestoredState?, UntrackableReason>, Network)
}

// MARK: - Reducer

public let deepLinkReducer = Reducer<Void, DeepLinkAction, DeepLinkEnvironment> { state, action, environment in
  struct TimerID: Hashable {}
  
  let timer = Effect.timer(
    id: TimerID(),
    every: 5,
    on: DispatchQueue.main.eraseToAnyScheduler()
  )
  .map(constant(DeepLinkAction.deepLinkTimerFired))
  
  switch action {
  case let .deepLinkOpened(activity):
    return .merge(
      environment
      .continueUserActivity(activity)
      .fireAndForget(),
      timer
    )
  case .deepLinkTimerFired:
    return .cancel(id: TimerID())
  case .finishedLaunching:
    return environment
      .subscribeToDeepLinks()
      .map(DeepLinkAction.receivedDeepLink)
      .eraseToEffect()
  case .receivedDeepLink:
    return .none
  case .restoredState:
    return timer
  }
}


