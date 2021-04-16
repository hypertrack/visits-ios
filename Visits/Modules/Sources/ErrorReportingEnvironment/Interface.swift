import ComposableArchitecture
import NonEmpty
import Tagged
import Types


public struct ErrorReportingEnvironment {
  
  public var addBreadcrumb:         (BreadcrumbType, BreadcrumbMessage) -> Effect<Never, Never>
  public var capture:               (Message)                           -> Effect<Never, Never>
  public var startErrorMonitoring:  ()                                  -> Effect<Never, Never>
  public var updateUser:            (DeviceID)                          -> Effect<Never, Never>
  
  public init(
    addBreadcrumb:        @escaping (BreadcrumbType, BreadcrumbMessage) -> Effect<Never, Never>,
    capture:              @escaping (Message)                           -> Effect<Never, Never>,
    startErrorMonitoring: @escaping ()                                  -> Effect<Never, Never>,
    updateUser:           @escaping (DeviceID)                          -> Effect<Never, Never>
  ) {
    self.addBreadcrumb = addBreadcrumb
    self.capture = capture
    self.startErrorMonitoring = startErrorMonitoring
    self.updateUser = updateUser
  }
}

public typealias BreadcrumbMessage = Tagged<(ErrorReportingEnvironment, addBreadcrumb: ()), NonEmptyString>
public typealias Message           = Tagged<(ErrorReportingEnvironment, capture: ()),       NonEmptyString>
public enum BreadcrumbType: String, Equatable { case state, action }
