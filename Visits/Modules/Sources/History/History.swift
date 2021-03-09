import Coordinate

public struct History: Equatable {
  public init(
    coordinates: [Coordinate],
    trackedDuration: UInt = 0,
    driveDistance: UInt = 0,
    driveDuration: UInt = 0,
    walkSteps: UInt = 0,
    walkDuration: UInt = 0,
    stopDuration: UInt = 0
  ) {
    self.coordinates = coordinates
    self.trackedDuration = trackedDuration
    self.driveDistance = driveDistance
    self.driveDuration = driveDuration
    self.walkSteps = walkSteps
    self.walkDuration = walkDuration
    self.stopDuration = stopDuration
  }

  public var coordinates: [Coordinate]
  public var trackedDuration: UInt
  public var driveDistance: UInt
  public var driveDuration: UInt
  public var walkSteps: UInt
  public var walkDuration: UInt
  public var stopDuration: UInt
}
