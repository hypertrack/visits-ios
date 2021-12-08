import Foundation


public struct OrderRequest {
  public var id: Order.ID?
  public var createdAt: Date?
  public var location: Coordinate?
  public var address: Address?
  public var status: Order.Status?
  public var note: Order.Note?
  public var metadata: [Name: Order.Contents]
  
  public init(
    id: Order.ID? = nil,
    createdAt: Date? = nil,
    location: Coordinate? = nil,
    address: Address? = nil,
    status: Order.Status?,
    note: Order.Note? = nil,
    metadata: [Name: Order.Contents] = [:]
  ) {
    self.id = id
    self.createdAt = createdAt
    self.location = location
    self.address = address
    self.status = status
    self.note = note
    self.metadata = metadata
  }
}

extension OrderRequest: Equatable {}
extension OrderRequest: Hashable {}
extension OrderRequest: Identifiable {}

public struct TripRequest {
  public var order: OrderRequest?
  public var id: Trip.ID?
  
  public init(
    id: Trip.ID? = nil,
    order: OrderRequest?) {
      self.id = id
      self.order = order
    }
}

extension TripRequest: Equatable {}
extension TripRequest: Hashable {}
extension TripRequest: Identifiable {}
