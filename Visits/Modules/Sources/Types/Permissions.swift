public enum LocationPermissions: Equatable {
  case authorizedAlways, authorizedWhenInUse, denied, disabled, notDetermined, restricted
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

public extension Permissions {
  static let granted = Self(locationAccuracy: .full, locationPermissions: .authorizedAlways, motionPermissions: .authorized)
}

public enum LocationAlwaysPermissions: Equatable {
  case requestedAfterWhenInUse
  case notRequested
}
