import Foundation

public struct RestoredState: Equatable {
  public enum Flow: Equatable {
    case firstRun
    case signIn(Email?)
    case main(TabSelection, PublishableKey, Name, WorkerHandle, Date, Date)
  }

  public var experience: Experience
  public var flow: Flow
  public var locationAlways: LocationAlwaysPermissions
  public var pushStatus: PushStatus
  public var version: AppVersion

  public init(
    experience: Experience,
    flow: RestoredState.Flow,
    locationAlways: LocationAlwaysPermissions,
    pushStatus: PushStatus,
    version: AppVersion
  ) {
    self.experience = experience
    self.flow = flow
    self.locationAlways = locationAlways
    self.pushStatus = pushStatus
    self.version = version
  }
}
