import APIEnvironment
import Combine
import ComposableArchitecture
import Foundation
import LogEnvironment
import NonEmpty
import Tagged
import Types
import Utility

func getVisits(_ token: Token.Value, _ wh: WorkerHandle, _ from: Date, _ to: Date) -> Effect<Result<PlacesVisitsSummary, APIError<Token.Expired>>, Never> {
  logEffect("getVisits")

  return callAPI(
    request: placesVisitsRequest(auth: token, workerHandle: wh, from: from, to: to, paginationToken: nil),
    success: PlacesVisitsSummary.self
  )
  .mapError(fromNever)
  .eraseToAnyPublisher()
  .catchToEffect()
}

func placesVisitsRequest(auth token: Token.Value, workerHandle: WorkerHandle,  from: Date, to: Date, paginationToken: PaginationToken?) -> URLRequest {
  var components = URLComponents()
  components.scheme = "https"
  components.host = "live-app-backend.htprod.hypertrack.com"
  components.path = "/client/visits"
  components.queryItems = [
    URLQueryItem(name: "worker_handle", value: workerHandle.string),
//    URLQueryItem(name: "visited_at_from", value: DateFormatter.iso8601MillisecondsDateFormatter.string(from: from)),
//    URLQueryItem(name: "visited_at_to", value: DateFormatter.iso8601MillisecondsDateFormatter.string(from: to))
  ]
  if let paginationToken = paginationToken, let queryItems = components.queryItems {
    components.queryItems = queryItems + [
      URLQueryItem(name: "pagination_token", value: "\(paginationToken)")
    ]
  }
  
  var request = URLRequest(url: components.url!)
  request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
  request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
  request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
  request.httpMethod = "GET"
  return request
}
