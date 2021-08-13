import Utility
import ComposableArchitecture


public struct OperationalState: Equatable {
  public var alert: Alert?
  public var experience: Experience
  public var flow: AppFlow
  public var locationAlways: LocationAlwaysPermissions
  public var pushStatus: PushStatus
  public var sdk: SDKStatusUpdate
  public var version: AppVersion
  public var visibility: AppVisibility
  
  public init(alert: Alert? = nil, experience: Experience, flow: AppFlow, locationAlways: LocationAlwaysPermissions, pushStatus: PushStatus, sdk: SDKStatusUpdate, version: AppVersion, visibility: AppVisibility) {
    self.alert = alert; self.experience = experience; self.flow = flow; self.locationAlways = locationAlways; self.pushStatus = pushStatus; self.sdk = sdk; self.version = version; self.visibility = visibility
  }
}
