import NonEmpty
import Prelude
import Tagged


public struct Address {
  public var street: Street?
  public var fullAddress: FullAddress?
  
  public init(
    street: Street? = nil,
    fullAddress: FullAddress? = nil
  ) {
    self.street = street
    self.fullAddress = fullAddress
  }
}

public typealias Street      = Tagged<(Address, street:      ()), NonEmptyString>
public typealias FullAddress = Tagged<(Address, fullAddress: ()), NonEmptyString>

public extension Address {
  static let none: Self = .init(street: nil, fullAddress: nil)
  
  init(string: String) {
    var splitted = string.split(separator: ",")
    if splitted.count > 2 {
      splitted.removeSubrange(2...)
      let candidate = String(splitted.joined(separator: ","))
      street = candidate |>  NonEmptyString.init(rawValue:) <¡> Street.init(rawValue:)
    } else {
      street = nil
    }
    fullAddress = string |> NonEmptyString.init(rawValue:) <¡> FullAddress.init(rawValue:)
  }
  
  var anyAddress: NonEmptyString? {
    street?.rawValue ?? fullAddress?.rawValue
  }
}



extension Address: Equatable {}
extension Address: Hashable {}
extension Address: Codable {}
