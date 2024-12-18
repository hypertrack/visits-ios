import APIEnvironment
import Combine
import ComposableArchitecture
import Foundation
import LogEnvironment
import NonEmpty
import Tagged
import Types
import Utility

func getWorkers(_ token: Token.Value, profileFilter: JSON, paginationToken: String?) -> Effect<Result<[RemoteWorker], APIError<Token.Expired>>, Never> {
  logEffect("getWorkers")

  return callAPI(
    request: workersRequest(auth: token, profileFilter: profileFilter, paginationToken: paginationToken),
    success: WorkersResponse.self
  )
  .map { response in
      response.workers
  }
  .mapError(fromNever)
  .eraseToAnyPublisher()
  .catchToEffect()
}

func workersRequest(auth token: Token.Value, profileFilter: JSON, paginationToken: String?) -> URLRequest {
  var components = URLComponents()
  components.scheme = "https"
  components.host = "live-app-backend.htprod.hypertrack.com"
  components.path = "/client/workers"

  let profileFilterJsonData = try? JSONEncoder().encode(profileFilter)
  let profileFilterJsonString = String(data: profileFilterJsonData!, encoding: .utf8)!
   
  components.queryItems = [
    URLQueryItem(name: "include_schedule", value: "false"),
    URLQueryItem(name: "include_summary", value: "false"),
    URLQueryItem(name: "profile", value: profileFilterJsonString),
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

struct WorkersResponse: Decodable {
  var workers: [RemoteWorker]
  var paginationToken: String?
  
  enum CodingKeys: String, CodingKey {
    case workers = "workers"
    case paginationToken = "pagination_token"
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    workers = try container.decode([RemoteWorker].self, forKey: .workers)
    paginationToken = try container.decodeIfPresent(String.self, forKey: .paginationToken)
  }
}
