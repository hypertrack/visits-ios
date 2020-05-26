import ComposableArchitecture
import Prelude


// MARK: - State

public struct TrackingState: Equatable {
  public var driverID: NonEmptyString
  public var publishableKey: NonEmptyString
  public var trackingStatus: TrackingStatus
  
  public init(driverID: NonEmptyString, publishableKey: NonEmptyString, trackingStatus: TrackingStatus) {
    self.driverID = driverID
    self.publishableKey = publishableKey
    self.trackingStatus = trackingStatus
  }
}

public enum TrackingStatus: Equatable {
  case tracking
  case notTracking(freeLimitReached: Bool)
}

// MARK: - Action

public enum TrackingAction: Equatable {
  case becameTrackable
  case enteredForeground
  case trackingStarted
  case trackingStopped
  case trialEnded
}

// MARK: - Environment

public struct TrackingEnvironment {
  public var checkInWithPublishableKey: (NonEmptyString) -> Effect<Never, Never>
  public var setDriverID: (NonEmptyString) -> Effect<Never, Never>
  public var subscribeToTrackingStarted: () -> Effect<Void, Never>
  public var subscribeToTrackingStopped: () -> Effect<Void, Never>
  public var subscribeToTrialEnded: () -> Effect<Void, Never>
  public var sync: () -> Effect<Never, Never>
  
  public init(
    checkInWithPublishableKey: @escaping (NonEmptyString) -> Effect<Never, Never>,
    setDriverID: @escaping (NonEmptyString) -> Effect<Never, Never>,
    subscribeToTrackingStarted: @escaping () -> Effect<Void, Never>,
    subscribeToTrackingStopped: @escaping () -> Effect<Void, Never>,
    subscribeToTrialEnded: @escaping () -> Effect<Void, Never>,
    sync: @escaping () -> Effect<Never, Never>
  ) {
    self.checkInWithPublishableKey = checkInWithPublishableKey
    self.setDriverID = setDriverID
    self.subscribeToTrackingStarted = subscribeToTrackingStarted
    self.subscribeToTrackingStopped = subscribeToTrackingStopped
    self.subscribeToTrialEnded = subscribeToTrialEnded
    self.sync = sync
  }
}

// MARK: - Reducer

public let trackingReducer = Reducer<TrackingState, TrackingAction, SystemEnvironment<TrackingEnvironment>> { state, action, environment in
  switch action {
  case .becameTrackable:
    return .merge(
      environment
        .subscribeToTrackingStarted()
        .receive(on: environment.mainQueue())
        .map(const(TrackingAction.trackingStarted))
        .eraseToEffect(),
      environment
        .subscribeToTrackingStopped()
        .receive(on: environment.mainQueue())
        .map(const(TrackingAction.trackingStopped))
        .eraseToEffect(),
      environment
        .subscribeToTrialEnded()
        .receive(on: environment.mainQueue())
        .map(const(TrackingAction.trialEnded))
        .eraseToEffect(),
      .concatenate(
        environment
          .checkInWithPublishableKey(state.publishableKey)
          .fireAndForget(),
        environment
          .setDriverID(state.driverID)
          .fireAndForget()
      )
    )
  case .enteredForeground:
    return environment
      .sync()
      .fireAndForget()
  case .trackingStarted:
    state.trackingStatus = .tracking
    return .none
  case .trackingStopped:
    if case .tracking = state.trackingStatus {
      state.trackingStatus = .notTracking(freeLimitReached: false)
    }
    return .none
  case .trialEnded:
    state.trackingStatus = .notTracking(freeLimitReached: true)
    return .none
  }
}
