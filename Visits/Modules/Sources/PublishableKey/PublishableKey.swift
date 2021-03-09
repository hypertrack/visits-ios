import Tagged
import NonEmpty

public typealias PublishableKey = Tagged<PublishableKeyTag, NonEmptyString>
public enum PublishableKeyTag {}
