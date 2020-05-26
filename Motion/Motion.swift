import ComposableArchitecture


// MARK: - State

public enum MotionState: Equatable {
  
  public enum Final: Equatable {
    case denied
    case restart
  }
  
  public enum Runtime: Equatable {
    case authorized
    case restricted
    case unknown
  }
  
  public enum Starting: Equatable {
    case authorized
    case notDetermined
    case restricted
  }
  
  case final(Final)
  case runtime(Runtime)
  case starting(Starting)
}

extension MotionState {
  public var needsChecking: Bool {
    switch self {
    case .final, .starting(.notDetermined):
      return false
    default:
      return true
    }
  }
}

// MARK: - Action

public enum MotionAction: Equatable {
  public enum Update: Equatable {
    case authorized
    case denied
    case restricted
    case unknown
  }
  
  case appAppeared
  case changed(Update)
  case check
  case enteredForeground
}

// MARK: - Environment

public struct MotionEnvironment {
  public var check: () -> Effect<MotionAction.Update, Never>
  
  public init(check: @escaping () -> Effect<MotionAction.Update, Never>) {
    self.check = check
  }
}

// MARK: - Reducer

public let motionReducer = Reducer<MotionState, MotionAction, SystemEnvironment<MotionEnvironment>> { state, action, environment in
  switch action {
  case let .changed(update):
    switch update {
    case .authorized:
      state = .runtime(.authorized)
    case .denied:
      state = .final(.denied)
    case .restricted:
      state = .runtime(.restricted)
    case .unknown:
      if case .starting(.notDetermined) = state {
        state = .final(.restart)
      } else {
        state = .runtime(.unknown)
      }
    }
    return .none
  case .check:
    return environment
    .check()
    .receive(on: environment.mainQueue())
    .map(MotionAction.changed)
    .eraseToEffect()
  case .appAppeared, .enteredForeground:
    if state == .starting(.notDetermined) {
      return .none
    } else {
      return environment
      .check()
      .receive(on: environment.mainQueue())
      .map(MotionAction.changed)
      .eraseToEffect()
    }
  }
}
