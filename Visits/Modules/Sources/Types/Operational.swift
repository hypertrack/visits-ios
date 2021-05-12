import Prelude
import ComposableArchitecture


public struct OperationalState: Equatable {
  public var alert: Either<AlertState<ErrorAlertAction>, AlertState<ErrorReportingAlertAction>>?
  public var experience: Experience
  public var flow: AppFlow
  public var locationAlways: LocationAlwaysPermissions
  public var pushStatus: PushStatus
  public var sdk: SDKStatusUpdate
  
  public init(alert: Either<AlertState<ErrorAlertAction>, AlertState<ErrorReportingAlertAction>>? = nil, experience: Experience, flow: AppFlow, locationAlways: LocationAlwaysPermissions, pushStatus: PushStatus, sdk: SDKStatusUpdate) {
    self.alert = alert; self.experience = experience; self.flow = flow; self.locationAlways = locationAlways; self.pushStatus = pushStatus; self.sdk = sdk
  }
}
