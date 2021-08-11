import APIEnvironment
import Combine
import ComposableArchitecture
import LogEnvironment
import NonEmpty
import Utility
import Types


func getIntegrationEntities(
  _ token:  Token.Value,
  _ limit:  IntegrationEntity.Limit,
  _ search: IntegrationEntity.Search
) -> Effect<Result<[IntegrationEntity], APIError<Token.Expired>>, Never> {
  logEffect("getIntegrationEntities")
  
  return callAPI(
    request: integrationEntitiesRequest(auth: token, limit: limit, search: search),
    success: IntegrationEntitiesResponse.self,
    failure: Token.Expired.self
  )
  .map(\.integrationEntities)
  .catchToEffect()
}

func integrationEntitiesRequest(auth token: Token.Value, limit: IntegrationEntity.Limit, search: IntegrationEntity.Search) -> URLRequest {
  var components = URLComponents()
  components.scheme = "https"
  components.host = "live-app-backend.htprod.hypertrack.com"
  components.path = "/client/get_entity_data"
  components.queryItems = [URLQueryItem(name: "limit", value: "\(limit)")]
    + (search.isEmpty ? [] : [URLQueryItem(name: "search_string", value: search.rawValue)])
  
  var request = URLRequest(url: components.url!)
  
  request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
  request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
  request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
  request.httpMethod = "GET"
  return request
}

private struct IntegrationEntitiesResponse {
  let integrationEntities: [IntegrationEntity]
}

extension IntegrationEntitiesResponse: Decodable {
  enum CodingKeys: String, CodingKey {
    case data
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    self.init(integrationEntities: try values.decode([IntegrationEntity].self, forKey: .data))
  }
}

extension IntegrationEntity: Decodable {
  enum CodingKeys: String, CodingKey {
    case id, name
  }
  
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    let id = try values.decode(IntegrationEntity.ID.self, forKey: .id)
    let name = try values.decode(IntegrationEntity.Name.self, forKey: .name)
    
    self.init(id: id, name: name)
  }
}
