import Foundation
import NonEmpty


public extension HTTPURLResponse {
  var prettyPrinted: NonEmptyString {
    """
    URL:         \(url?.absoluteString ?? "Broken URL")
    
    Headers:     \(allHeaderFields.reduce("", headerReducer))
    
    MIME:        \(mimeType ?? "Not provided")
    
    Status code: \(statusCode)
    """
  }
}

private func headerReducer(sum: String, header: (key: AnyHashable, value: Any)) -> String
{ sum + "\n\(header.key): \(header.value)" }
