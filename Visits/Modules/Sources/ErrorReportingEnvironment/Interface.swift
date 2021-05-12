import ComposableArchitecture
import NonEmpty
import Tagged
import Types


public struct ErrorReportingEnvironment {
  
  public var addBreadcrumb:         (BreadcrumbType, BreadcrumbMessage) -> Effect<Never, Never>
  public var capture:               (CaptureMessage)                    -> Effect<Never, Never>
  public var startErrorMonitoring:  ()                                  -> Effect<Never, Never>
  public var updateUser:            (DeviceID)                          -> Effect<Never, Never>
  
  public init(
    addBreadcrumb:        @escaping (BreadcrumbType, BreadcrumbMessage) -> Effect<Never, Never>,
    capture:              @escaping (CaptureMessage)                    -> Effect<Never, Never>,
    startErrorMonitoring: @escaping ()                                  -> Effect<Never, Never>,
    updateUser:           @escaping (DeviceID)                          -> Effect<Never, Never>
  ) {
    self.addBreadcrumb = addBreadcrumb
    self.capture = capture
    self.startErrorMonitoring = startErrorMonitoring
    self.updateUser = updateUser
  }
}
