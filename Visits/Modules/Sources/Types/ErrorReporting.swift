import NonEmpty
import Tagged


public typealias BreadcrumbMessage = Tagged<BreadcrumbMessageTag, NonEmptyString>; public enum BreadcrumbMessageTag {}

public enum BreadcrumbType: String, Equatable { case state, action }

public typealias CaptureMessage = Tagged<CaptureMessageTag, NonEmptyString>; public enum CaptureMessageTag {}
