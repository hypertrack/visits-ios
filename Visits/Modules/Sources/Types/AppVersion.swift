import NonEmpty
import Tagged


public typealias AppVersion = Tagged<AppVersionTag, NonEmptyString>
public enum AppVersionTag {}
