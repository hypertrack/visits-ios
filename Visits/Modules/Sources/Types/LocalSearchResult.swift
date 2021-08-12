import NonEmpty
import Tagged


public enum LocalSearchResult: Equatable {
  case result(MapPlace)
  case results(MapPlace, NonEmptyArray<MapPlace>)
  case empty
  case error(Error)
  case fatalError
  
  public typealias Error = Tagged<(LocalSearchResult, error: ()), NonEmptyString>
}

public struct MapPlace: Hashable {
  public init(name: MapPlace.Name? = nil, address: Address, location: Coordinate) {
    self.name = name; self.address = address; self.location = location
  }
  
  public var name: Name?
  public var address: Address
  public var location: Coordinate
  
  public typealias Name = Tagged<(MapPlace, name: ()), NonEmptyString>
}
