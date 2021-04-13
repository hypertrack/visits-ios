import Foundation


public enum APIError<KnownError: Equatable>: Equatable, Error {
  case error(KnownError)
  case network(URLError)
  case unknown(HTTPURLResponse)
  
  public func map<T>(_ f: (KnownError) -> T) -> APIError<T> {
    switch self {
    case let .error(error):      return .error(f(error))
    case let .network(error):    return .network(error)
    case let .unknown(response): return .unknown(response)
    }
  }
}
