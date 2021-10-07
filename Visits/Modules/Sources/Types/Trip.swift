import NonEmpty
import Foundation
import IdentifiedCollections

public struct Trip: Identifiable {
  public var id: NonEmptyString
  public var createdAt: Date
  public var status: Status
  public var orders: IdentifiedArrayOf<Order>
  
  public enum Status { case active, completed, processingCompletion }
  
  public init(id: NonEmptyString, createdAt: Date, status: Status, orders: [Order]) {
    self.id = id
    self.createdAt = createdAt
    self.status = status
    self.orders = IdentifiedArrayOf<Order>(uniqueElements: orders)
  }
}

extension Trip.Status: Equatable {}
extension Trip: Equatable {}
