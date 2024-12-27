import Foundation
import NonEmpty


public struct PlacesVisitsSummary {
    var visits: [Place.Visit]
}

extension PlacesVisitsSummary: Decodable {
  enum CodingKeys: String, CodingKey {
    case visits
  }
  
    public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    visits = try container.decode([Place.Visit].self, forKey: .visits)
  }
}
