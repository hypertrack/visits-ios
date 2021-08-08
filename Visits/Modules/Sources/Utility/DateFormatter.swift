import Foundation

public extension DateFormatter {
  static func stringTime(_ date: Date) -> String {
    let dateFormat = DateFormatter()
    dateFormat.locale = Locale(identifier: "en_US_POSIX")
    dateFormat.dateFormat = "h:mm a"
    return dateFormat.string(from: date)
  }
  
  static func stringDate(_ date: Date) -> String {
    let dateFormat = DateFormatter()
    dateFormat.locale = Locale(identifier: "en_US_POSIX")
    if Calendar.current.isDate(date, equalTo: Date(), toGranularity: .year) {
      dateFormat.dateFormat = "MMM d"
    } else {
      dateFormat.dateFormat = "MMM d, yyyy"
    }
    return dateFormat.string(from: date)
  }
  
  static let iso8601DateFormatter: DateFormatter = {
    let enUSPOSIXLocale = Locale(identifier: "en_US_POSIX")
    let iso8601DateFormatter = DateFormatter()
    iso8601DateFormatter.locale = enUSPOSIXLocale
    iso8601DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    iso8601DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    return iso8601DateFormatter
  }()

  static let iso8601MillisecondsDateFormatter: DateFormatter = {
    let enUSPOSIXLocale = Locale(identifier: "en_US_POSIX")
    let iso8601DateFormatter = DateFormatter()
    iso8601DateFormatter.locale = enUSPOSIXLocale
    iso8601DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    iso8601DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    return iso8601DateFormatter
  }()

  static let iso8601MicrosecondsDateFormatter: DateFormatter = {
    let enUSPOSIXLocale = Locale(identifier: "en_US_POSIX")
    let iso8601DateFormatter = DateFormatter()
    iso8601DateFormatter.locale = enUSPOSIXLocale
    iso8601DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
    iso8601DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    return iso8601DateFormatter
  }()

  static let iso8601MicrosecondsWithZZZZZDateFormatter: DateFormatter = {
    let enUSPOSIXLocale = Locale(identifier: "en_US_POSIX")
    let iso8601DateFormatter = DateFormatter()
    iso8601DateFormatter.locale = enUSPOSIXLocale
    iso8601DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZZZZ"
    iso8601DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    return iso8601DateFormatter
  }()

  static func date(fromISO8601String string: String) -> Date? {
    if let dateWithMillisecondsZZZZZ = iso8601MicrosecondsWithZZZZZDateFormatter
      .date(from: string) {
      return dateWithMillisecondsZZZZZ
    }

    if let dateWithMicroseconds = iso8601MicrosecondsDateFormatter
      .date(from: string) {
      return dateWithMicroseconds
    }

    if let dateWithMilliseconds = iso8601MillisecondsDateFormatter
      .date(from: string) {
      return dateWithMilliseconds
    }

    if let date = iso8601DateFormatter.date(from: string) {
      return date
    }
    return nil
  }
}

public extension String {
  var iso8601: Date? {
    return DateFormatter.date(fromISO8601String: self)
  }
}
