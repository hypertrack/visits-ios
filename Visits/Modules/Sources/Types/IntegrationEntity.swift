import NonEmpty
import Tagged


public struct IntegrationEntity: Equatable, Hashable {
  public var id: ID
  public var name: Name
  
  public init(id: ID, name: Name) { self.id = id; self.name = name }
  public typealias ID    = Tagged<(IntegrationEntity, id: ()),    NonEmptyString>
  public typealias Name  = Tagged<(IntegrationEntity, name: ()),  NonEmptyString>
}


public typealias IntegrationLimit =  Tagged<(IntegrationLimitTag, limit: ()),  UInt>
public enum IntegrationLimitTag {}

public typealias IntegrationSearch = Tagged<(IntegrationSearchTag, search: ()), String>
public enum IntegrationSearchTag {}

