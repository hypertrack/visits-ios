import Foundation
import NonEmpty
import Tagged
import Utility


public enum APIError<KnownError: Equatable>: Equatable, Error {
  case error(KnownError, HTTPURLResponse, Data)
  case api(HyperTrackAPIError, HTTPURLResponse, Data)
  case server(HyperTrackCriticalAPIError, HTTPURLResponse, Data)
  case network(URLError)
  case unknown(ParsingError, HTTPURLResponse, Data)

  public func map<T>(_ f: (KnownError) -> T) -> APIError<T> {
    switch self {
    case let .error(e, r, d):   return .error(f(e), r, d)
    case let .api(a, r, d):     return .api(a, r, d)
    case let .server(s, r, d):  return .server(s, r, d)
    case let .network(u):       return .network(u)
    case let .unknown(p, r, d): return .unknown(rewrap(p), r, d)
    }
  }
  
}

public typealias ParsingError = Tagged<ParsingErrorTag, NonEmptyString>
public enum ParsingErrorTag {}

private func rewrap<Source, Value, Destination>(_ source: Tagged<Source, Value>) -> Tagged<Destination, Value> {
  .init(rawValue: source.rawValue)
}

public func toNever<KnownError>(_ apiError: APIError<KnownError>) -> APIError<Never>? {
  switch apiError {
  case     .error:            return nil
  case let .api(a, r, d):     return .api(a, r, d)
  case let .server(s, r, d):  return .server(s, r, d)
  case let .network(u):       return .network(u)
  case let .unknown(p, r, d): return .unknown(rewrap(p), r, d)
  }
}

public func fromNever<KnownError>(_ apiError: APIError<Never>) -> APIError<KnownError> {
  switch apiError {
  case let .api(a, r, d):     return .api(a, r, d)
  case let .server(s, r, d):  return .server(s, r, d)
  case let .network(u):       return .network(u)
  case let .unknown(p, r, d): return .unknown(rewrap(p), r, d)
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
