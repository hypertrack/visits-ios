import NonEmpty
import Tagged

public extension Tagged where RawValue == NonEmptyString {
  var string: String { self.rawValue.rawValue }
}
