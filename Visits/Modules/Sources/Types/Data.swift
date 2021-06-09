import Foundation
import NonEmpty
import Utility


public extension Data {
  var prettyPrintedJSON: NonEmptyString {
    if let prettyData = prettyPrintJSONData(self) {
      return prettyData
    } else {
      return "Can't parse data to JSON"
    }
  }
}

private func prettyPrintJSONData(_ jsonData: Data) -> NonEmptyString? {
  guard
    let object = try? JSONSerialization.jsonObject(with: jsonData, options: []),
    let data = try? JSONSerialization.data(
      withJSONObject: object,
      options: [.prettyPrinted]
    ), let prettyPrintedString = String(data: data, encoding: .utf8) >>- NonEmptyString.init(rawValue:)
  else { return nil }
  return prettyPrintedString
}
