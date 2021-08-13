import ComposableArchitecture


public enum Alert: Equatable {
  case errorAlert(AlertState<ErrorAlertAction>)
  case sendErrorReport(AlertState<SendErrorReportAction>)

  public var errorAlert: AlertState<ErrorAlertAction>? {
    get {
      guard case let .errorAlert(value) = self else { return nil }
      return value
    }
    set {
      guard case .errorAlert = self, let newValue = newValue else { return }
      self = .errorAlert(newValue)
    }
  }

  public var sendErrorReport: AlertState<SendErrorReportAction>? {
    get {
      guard case let .sendErrorReport(value) = self else { return nil }
      return value
    }
    set {
      guard case .sendErrorReport = self, let newValue = newValue else { return }
      self = .sendErrorReport(newValue)
    }
  }
}

public enum ErrorAlertAction: Equatable {
  case ok
}

public enum SendErrorReportAction: Equatable {
  case yes, no
}
