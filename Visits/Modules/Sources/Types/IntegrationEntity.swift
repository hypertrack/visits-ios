import NonEmpty
import Tagged


public struct IntegrationEntity: Equatable {
  public var id: ID
  public var name: Name
  
  public init(id: ID, name: Name) { self.id = id; self.name = name }
  public typealias ID    = Tagged<(IntegrationEntity, id: ()),    NonEmptyString>
  public typealias Name  = Tagged<(IntegrationEntity, name: ()),  NonEmptyString>
  
}

public typealias Limit =  Tagged<(IntegrationEntity, limit: ()),  UInt>
public typealias Search = Tagged<(IntegrationEntity, search: ()), String>
