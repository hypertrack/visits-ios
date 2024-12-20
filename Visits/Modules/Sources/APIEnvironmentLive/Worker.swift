import APIEnvironment
import Combine
import ComposableArchitecture
import Foundation
import LogEnvironment
import NonEmpty
import Tagged
import Types
import Utility

func getWorker(_ token: Token.Value, _ wh: WorkerHandle) -> Effect<Result<RemoteWorker, APIError<Token.Expired>>, Never> {
  logEffect("getWorker")

  return callAPI(
    request: workerRequest(auth: token, workerHandle: wh),
    success: RemoteWorker.self
  )
  .mapError(fromNever)
  .eraseToAnyPublisher()
  .catchToEffect()
}

func workerRequest(auth token: Token.Value, workerHandle: WorkerHandle) -> URLRequest {
  var components = URLComponents()
  components.scheme = "https"
  components.host = "live-app-backend.htprod.hypertrack.com"
  components.path = "/client/workers/\(workerHandle.string)"
    
  components.queryItems = [
    URLQueryItem(name: "worker_handle", value: workerHandle.rawValue.rawValue),
    URLQueryItem(name: "include_schedule", value: "false"),
    URLQueryItem(name: "include_summary", value: "false"),
    URLQueryItem(name: "include_timeline", value: "false"),
    // URLQueryItem(name: "from_time", value: DateFormatter.iso8601MillisecondsDateFormatter.string(from: date)),
    // URLQueryItem(name: "to_time", value: DateFormatter.iso8601MillisecondsDateFormatter.string(from: date1))
    // URLQueryItem(name: "visited_at_from", value: DateFormatter.iso8601MillisecondsDateFormatter.string(from: date)),
    // URLQueryItem(name: "visited_at_to", value: DateFormatter.iso8601MillisecondsDateFormatter.string(from: date1))
  ]
//  if let paginationToken = paginationToken, let queryItems = components.queryItems {
//    components.queryItems = queryItems + [
//      URLQueryItem(name: "pagination_token", value: "\(paginationToken)")
//    ]
//  }
  
  var request = URLRequest(url: components.url!)
  request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
  request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
  request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
  request.httpMethod = "GET"
  return request
}

struct RemoteWorker: Decodable {
  var profile: JSON.Object?
  var name: String?
  var workerHandle: WorkerHandle

  enum CodingKeys: String, CodingKey {
    case profile = "profile"
    case name = "name"
    case workerHandle = "worker_handle"
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    profile = try container.decodeIfPresent(JSON.Object.self, forKey: .profile)
    name = try container.decodeIfPresent(String.self, forKey: .name)
    let workerHandleString = try container.decode(String.self, forKey: .workerHandle)
      workerHandle = WorkerHandle.init(NonEmptyString.init(rawValue: workerHandleString)!)
  }
}