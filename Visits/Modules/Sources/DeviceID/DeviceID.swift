import NonEmpty
import Tagged

public typealias DeviceID = Tagged<DeviceIDTag, NonEmptyString>
public enum DeviceIDTag {}
