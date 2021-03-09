import Foundation


func prettyPrint(data: Data, response: URLResponse) {
  let responseData: String
  if let prettyData = prettyPrintJSONData(data) {
    responseData = prettyData
  } else {
    responseData = "Can't parse data to JSON"
  }
  
  if let httpResponse = response as? HTTPURLResponse {
    let headers = prettyPrintHTTPURLResponseHeaders(
      httpResponse.allHeaderFields
    )
    
    let string = """
    History Response: \(responseData)

    \("Status code: \(httpResponse.statusCode)")
    \("Headers: \(headers)")
    """
    print(string)
  } else {
    print("History Response: \(responseData)")
  }
}

let prettyPrintedOptionalNone = "nil"

func prettyPrintHTTPURLResponse(_ response: HTTPURLResponse?) -> String {
  switch response {
    case .none:
      return prettyPrintedOptionalNone
    case let .some(httpURLResponse):
      let headers = prettyPrintHTTPURLResponseHeaders(
        httpURLResponse.allHeaderFields
      )

      let string = """

      \("Status code: \(httpURLResponse.statusCode)")
      \("Headers: \(headers)")

      """
      return string
  }
}

func prettyPrintHTTPURLResponseHeaders(_ headers: [AnyHashable: Any]) -> String
{ headers.reduce("", headerReducer) }

func headerReducer(sum: String, header: (key: AnyHashable, value: Any)) -> String
{ sum + "\n\(header.key): \(header.value)" }

func prettyPrintJSONData(_ jsonData: Data) -> String? {
  guard
    let object = try? JSONSerialization.jsonObject(with: jsonData, options: []),
    let data = try? JSONSerialization.data(
      withJSONObject: object,
      options: [.prettyPrinted]
    ), let prettyPrintedString = String(data: data, encoding: .utf8)
  else { return nil }
  return prettyPrintedString
}
