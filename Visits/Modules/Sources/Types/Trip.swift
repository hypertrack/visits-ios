import NonEmpty
import Foundation
import IdentifiedCollections
import Tagged

public struct Trip: Identifiable {
  public var id: NonEmptyString
  public var createdAt: Date
  public var status: Status
  public var orders: IdentifiedArrayOf<Order>
  public var metadata: [Name: Contents]

  public enum Status { case active, completed, processingCompletion }
  
  public typealias Contents = Tagged<(Trip, contents: ()), NonEmptyString>
  public typealias Name     = Tagged<(Trip, name: ()),     NonEmptyString>
  
  public init(id: NonEmptyString, createdAt: Date, status: Status, orders: [Order], metadata: [Name: Contents] = [:]) {
    self.id = id
    self.createdAt = createdAt
    self.status = status
    self.orders = IdentifiedArrayOf<Order>(uniqueElements: orders)
    self.metadata = metadata
  }
}

extension Trip.Status: Equatable {}
extension Trip: Equatable {}
