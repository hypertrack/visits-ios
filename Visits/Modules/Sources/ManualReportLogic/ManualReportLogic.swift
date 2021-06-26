import ComposableArchitecture
import Types


// MARK: - State

public enum ManualReportState: Equatable {
  case dismissed
  case shown(AlertState<ErrorReportingAlertAction>)
}

// MARK: - Action

public enum ManualReportAction: Equatable {
  case alert(ErrorReportingAlertAction)
  case appWentOffScreen
  case shakeDetected
}

// MARK: - Environment

public struct ManualReportEnvironment {
  public var notifySuccess: () -> Effect<Never, Never>
  
  public init(notifySuccess: @escaping () -> Effect<Never, Never>) {
    self.notifySuccess = notifySuccess
  }
}

// MARK: - Reducer

public let manualReportReducer = Reducer<
  ManualReportState,
  ManualReportAction,
  ManualReportEnvironment
> { state, action, environment in
  switch action {
  case .shakeDetected:
    guard state == .dismissed else { return .none }
    
    state = .shown(
      .init(
        title: TextState("Is something wrong?"),
        message: TextState("Do you want to send a report?"),
        primaryButton: .default(TextState("Send"), send: .yes),
        secondaryButton: .destructive(TextState("Cancel"), send: .no)
      )
    )
    
    return .none
  case .alert(.yes):
    guard case .shown = state else { return .none }
    
    state = .dismissed
    
    return environment.notifySuccess().fireAndForget()
  case .appWentOffScreen, .alert(.no):
    guard case .shown = state else { return .none }
    
    state = .dismissed
    
    return .none
  }
}
