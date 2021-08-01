import Utility


public struct Profile: Equatable {
  public var name: Name
  public var metadata: JSON.Object
  
  public init(name: Name, metadata: JSON.Object) { self.name = name; self.metadata = metadata }
}
