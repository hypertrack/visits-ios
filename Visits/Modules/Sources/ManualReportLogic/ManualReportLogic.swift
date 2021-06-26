import ComposableArchitecture
import Types


// MARK: - State

public struct ManualReportState: Equatable {
  public enum Status: Equatable {
    case dismissed
    case shown(AlertState<ErrorReportingAlertAction>)
  }
  
  public var status: Status
  public var visibility: AppVisibility
  
  public init(status: Status, visibility: AppVisibility) {
    self.status = status; self.visibility = visibility
  }
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
    guard state.status == .dismissed, state.visibility == .onScreen  else { return .none }
    
    state.status = .shown(
      .init(
        title: TextState("Is something wrong?"),
        message: TextState("Do you want to send a report?"),
        primaryButton: .default(TextState("Send"), send: .yes),
        secondaryButton: .destructive(TextState("Cancel"), send: .no)
      )
    )
    
    return .none
  case .alert(.yes):
    guard case .shown = state.status else { return .none }
    
    state.status = .dismissed
    
    return environment.notifySuccess().fireAndForget()
  case .appWentOffScreen, .alert(.no):
    guard case .shown = state.status else { return .none }
    
    state.status = .dismissed
    
    return .none
  }
}
