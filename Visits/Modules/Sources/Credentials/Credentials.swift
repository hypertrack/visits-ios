import NonEmpty
import Tagged

public typealias Email = Tagged<EmailTag, NonEmptyString>
public enum EmailTag {}

public typealias Password = Tagged<PasswordTag, NonEmptyString>
public enum PasswordTag {}
