public enum SDKUnlockedStatus: Equatable {
  case running
  case stopped
  case deleted
  case invalidPublishableKey
}

public enum LocationPermissions: Equatable {
  case authorized, denied, disabled, notDetermined, restricted
}

public enum LocationAccuracy: Equatable {
  case full, reduced
}

public enum MotionPermissions: Equatable {
  case authorized, denied, disabled, notDetermined
}

public struct Permissions: Equatable {
  public var locationAccuracy: LocationAccuracy
  public var locationPermissions: LocationPermissions
  public var motionPermissions: MotionPermissions
  
  public init(
    locationAccuracy: LocationAccuracy,
    locationPermissions: LocationPermissions,
    motionPermissions: MotionPermissions
  ) {
    self.locationAccuracy = locationAccuracy
    self.locationPermissions = locationPermissions
    self.motionPermissions = motionPermissions
  }
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
