import NonEmpty
import Foundation
import IdentifiedCollections
import Tagged

public struct Trip: Identifiable {
  public var id: ID
  public var createdAt: Date
  public var status: Status
  public var orders: IdentifiedArrayOf<Order>
  public var metadata: [Name: Contents]

  public enum Status { case active, completed, processingCompletion }

  public init(id: ID, createdAt: Date, status: Status, orders: [Order], metadata: [Name: Contents] = [:]) {
    self.id = id
    self.createdAt = createdAt
    self.status = status
    self.orders = IdentifiedArrayOf<Order>(uniqueElements: orders)
    self.metadata = metadata
  }

  // Newtypes
  public typealias ID       = Tagged<(Trip, id: ()),       NonEmptyString>
  public typealias Contents = Tagged<(Trip, contents: ()), NonEmptyString>
  public typealias Name     = Tagged<(Trip, name: ()),     NonEmptyString>
}

extension Trip.Status: Equatable {}
extension Trip: Equatable {}
