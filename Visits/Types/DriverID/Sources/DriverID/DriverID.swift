import NonEmpty
import Tagged

public typealias DriverID = Tagged<DriverIDTag, NonEmptyString>
public enum DriverIDTag {}
