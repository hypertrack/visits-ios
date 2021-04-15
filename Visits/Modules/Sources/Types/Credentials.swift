import Foundation
import NonEmpty
import Tagged

public typealias Email = Tagged<EmailTag, NonEmptyString>
public enum EmailTag {}

public extension Email {
  func cleanup() -> Email? {
    NonEmptyString(
      rawValue: self.string
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .lowercased()
    )
    .map(Email.init(rawValue:))
  }
  
  func isValid() -> Bool {
    (
      try! NSRegularExpression(pattern: "[^@]+@([^@]+)"))
      .firstMatch(
        in: self.string,
        options: [],
        range: NSRange(location: 0, length: self.string.utf16.count)
      ) != nil
  }
}

public typealias Password = Tagged<PasswordTag, NonEmptyString>
public enum PasswordTag {}

public extension Password {
  func isValid() -> Bool {
    self.count >= 8
  }
}

public typealias BusinessName = Tagged<BusinessNameTag, NonEmptyString>
public enum BusinessNameTag {}

public enum BusinessManages: String, Equatable { case visits, deliveries, rides }
public enum ManagesFor: String, Equatable {
  case myFleet = "my_workforce"
  case myCustomersFleet = "my_customers"
}

public struct VerificationCode: Equatable {
  public let first: Digit
  public let second: Digit
  public let third: Digit
  public let fourth: Digit
  public let fifth: Digit
  public let sixth: Digit
  
  public enum Digit: UInt, Equatable { case zero, one, two, three, four, five, six, seven, eight, nine }
  
  public init(
    first: VerificationCode.Digit,
    second: VerificationCode.Digit,
    third: VerificationCode.Digit,
    fourth: VerificationCode.Digit,
    fifth: VerificationCode.Digit,
    sixth: VerificationCode.Digit
  ) {
    self.first = first
    self.second = second
    self.third = third
    self.fourth = fourth
    self.fifth = fifth
    self.sixth = sixth
  }
}

public extension VerificationCode {
  init?(string: String) {
    guard case let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines),
          !trimmed.isEmpty, trimmed.count == 6
    else { return nil }
    
    var digits = Array(trimmed)
      .map(String.init)
      .compactMap(UInt.init)
      .compactMap(Digit.init(rawValue:))
    
    guard digits.count == 6 else { return nil }
    
    let first  = digits.removeFirst()
    let second = digits.removeFirst()
    let third  = digits.removeFirst()
    let fourth = digits.removeFirst()
    let fifth  = digits.removeFirst()
    let sixth  = digits.removeFirst()
    
    self.init(first: first, second: second, third: third, fourth: fourth, fifth: fifth, sixth: sixth)
  }
  
  var string: String {
    String(first.rawValue)
      + String(second.rawValue)
      + String(third.rawValue)
      + String(fourth.rawValue)
      + String(fifth.rawValue)
      + String(sixth.rawValue)
  }
}

public extension VerificationCode.Digit {
  init?(string: String) {
    guard let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines).first,
          let uint = UInt(String(trimmed))
    else { return nil }
    self.init(rawValue: uint)
  }
}
