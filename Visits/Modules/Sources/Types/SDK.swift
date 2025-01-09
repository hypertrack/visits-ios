public enum SDKUnlockedStatus: Equatable {
  case running
  case stopped
  case outage(Outage)
}

public enum SDKStatus: Equatable {
  case locked
  case unlocked(DeviceID, SDKUnlockedStatus)

  public var isRunning: Bool {
    switch self {
      case .unlocked(_, .running): return true
      default: return false
    }
  }
}

public struct SDKStatusUpdate: Equatable {
  public var status: SDKStatus

  public init(
    status: SDKStatus
  ) {
    self.status = status
  }
}

public enum Outage: Equatable {
  case blockedFromRunning
  case invalidPublishableKey
  case locationMocked
  case locationServicesDisabled
  case locationSignalLost
  case permissionLocationDenied
  case permissionLocationInsufficientForBackground
  case permissionLocationNotDetermined
  case permissionLocationProvisional
  case permissionLocationReducedAccuracy
  case permissionLocationRestricted
}
