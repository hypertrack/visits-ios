import Foundation

public enum ManualVisitsStatus: String {
  case showManualVisits
  case hideManualVisits
}

extension ManualVisitsStatus: Equatable {}
extension ManualVisitsStatus: Codable {}
