import NonEmpty
import Tagged

public typealias Name = Tagged<NameTag, NonEmptyString>
public enum NameTag {}
