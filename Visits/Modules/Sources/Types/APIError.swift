import Foundation
import NonEmpty
import Tagged


public enum APIError<KnownError: Equatable>: Equatable, Error {
  case error(KnownError)
  case api(HyperTrackAPIError)
  case server(HyperTrackCriticalAPIError)
  case network(URLError)
  case unknown(HTTPURLResponse)
  
  public func map<T>(_ f: (KnownError) -> T) -> APIError<T> {
    switch self {
    case let .error(error):      return .error(f(error))
    case let .api(api):          return .api(api)
    case let .server(server):    return .server(server)
    case let .network(error):    return .network(error)
    case let .unknown(response): return .unknown(response)
    }
  }
}

public func toNever<KnownError>(_ e: APIError<KnownError>) -> APIError<Never>? {
  switch e {
  case     .error:      return nil
  case let .api(e):     return .api(e)
  case let .server(e):  return .server(e)
  case let .network(e): return .network(e)
  case let .unknown(e): return .unknown(e)
  }
}

public func fromNever<KnownError>(_ e: APIError<Never>) -> APIError<KnownError> {
  switch e {
  case let .api(e):     return .api(e)
  case let .server(e):  return .server(e)
  case let .network(e): return .network(e)
  case let .unknown(e): return .unknown(e)
  }
}

public struct HyperTrackAPIError: Equatable, Decodable {
  public enum HTTPStatusCode: Int, Equatable, Decodable {
    case badRequest = 400
    case notFound = 404
    case methodNotAllowed = 405
    case internalServerError = 500
  }
  
  public var status: HTTPStatusCode
  public var code: ErrorClassCode
  public var title: ErrorClassSummary
  public var type: URL
  public var detail: DetailedDescription
  
  public typealias ErrorClassCode      = Tagged<(HyperTrackAPIError, code:               ()), NonEmptyString>
  public typealias ErrorClassSummary   = Tagged<(HyperTrackAPIError, summary:            ()), NonEmptyString>
  public typealias DetailedDescription = Tagged<(HyperTrackAPIError, detail:             ()), NonEmptyString>
}

public struct HyperTrackCriticalAPIError: Equatable, Decodable {
  public var message: NonEmptyString
}
