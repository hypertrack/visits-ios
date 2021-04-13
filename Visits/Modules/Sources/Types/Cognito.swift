import NonEmpty
import Tagged


public typealias CognitoError = Tagged<CognitoTag, NonEmptyString>
public enum CognitoTag {}
