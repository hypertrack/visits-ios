public enum SDKUnlockedStatus: Equatable {
  case running
  case stopped
  case deleted
  case invalidPublishableKey
}

public enum UntrackableReason: Equatable {
  case motionActivityServicesUnavalible
}

public enum SDKStatus: Equatable {
  case locked
  case unlocked(DeviceID, SDKUnlockedStatus)
}

public struct SDKStatusUpdate: Equatable {
  public var permissions: Permissions
  public var status: SDKStatus

  public init(
    permissions: Permissions,
    status: SDKStatus
  ) {
    self.permissions = permissions
    self.status = status
  }
}
