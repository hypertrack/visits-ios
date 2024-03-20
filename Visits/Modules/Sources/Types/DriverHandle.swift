import NonEmpty
import Tagged

public typealias DriverHandle = Tagged<DriverHandleTag, NonEmptyString>
public enum DriverHandleTag {}
