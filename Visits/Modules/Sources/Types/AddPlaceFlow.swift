import NonEmpty
import Tagged
import Utility


public struct AddPlace: Equatable {
  public var flow: AddPlaceFlow
  public var entities: [IntegrationEntity]
  
  public init(flow: AddPlaceFlow, entities: [IntegrationEntity]) { self.flow = flow; self.entities = entities }
}

public enum AddPlaceFlow: Equatable {
  case choosingCoordinate(GeocodedResult?)
  case choosingAddress(ChoosingAddress)
  case editingMetadata(AddPlaceMetadata)
}

public struct ChoosingAddress: Equatable {
  public var flow: ChoosingAddressFlow
  public var currentLocation: CurrentLocation
  public var results: [LocalSearchCompletion]
  
  public init(flow: ChoosingAddressFlow = .searching(.init()), currentLocation: CurrentLocation, results: [LocalSearchCompletion] = []) { self.flow = flow; self.currentLocation = currentLocation; self.results = results }
}

public enum ChoosingAddressFlow: Equatable {
  case searching(SearchingForAddress)
  case confirming(ConfirmingAddressLocation)
}

public struct SearchingForAddress: Equatable {
  public var search: AddressSearch?
  public var selected: LocalSearchCompletion?
  
  public init(search: AddressSearch? = nil, selected: LocalSearchCompletion? = nil) { self.search = search; self.selected = selected }
}

public struct ConfirmingAddressLocation: Equatable {
  public var search: AddressSearch
  public var selected: LocalSearchCompletion
  public var locations: NonEmptyArray<MapPlace>
  
  public init(search: AddressSearch, selected: LocalSearchCompletion, locations: NonEmptyArray<MapPlace>) { self.search = search; self.selected = selected; self.locations = locations }
}

public struct AddPlaceMetadata: Equatable {
  public var flow: AddPlaceMetadataFlow
  public var center: PlaceCenter
  public var customAddress: CustomAddress?
  public var radius: PlaceRadius
  public var description: PlaceDescription?
  
  public init(flow: AddPlaceMetadataFlow = .editing(nil), center: PlaceCenter, customAddress: CustomAddress? = nil, radius: PlaceRadius = .lowest, description: PlaceDescription? = nil) { self.flow = flow; self.center = center; self.customAddress = customAddress; self.radius = radius; self.description = description }
}

public enum AddPlaceMetadataFlow: Equatable {
  case editing(IntegrationEntity?)
  case choosingIntegration(ChoosingIntegration)
  case adding(IntegrationEntity)
}

public struct ChoosingIntegration: Equatable {
  public var search: IntegrationSearch
  public var status: IntegrationSearchStatus
  
  public init(search: IntegrationSearch, status: IntegrationSearchStatus) { self.search = search; self.status = status }
}

public typealias AddressSearch = Tagged<AddressSearchTag, NonEmptyString>
public enum AddressSearchTag {}

public typealias CustomAddress = Tagged<CustomAddressTag, NonEmptyString>
public enum CustomAddressTag {}

public typealias PlaceDescription = Tagged<PlaceDescriptionTag, NonEmptyString>
public enum PlaceDescriptionTag {}

public typealias PlaceCenter = Tagged<PlaceCenterTag, Coordinate>
public enum PlaceCenterTag {}

public typealias CurrentLocation = Tagged<CurrentLocationTag, Coordinate>
public enum CurrentLocationTag {}

public enum PlaceRadius: UInt16, Equatable, CaseIterable {
  case fifty = 50
  case hundred = 100
  case hundredFifty = 150
  case twoHundred = 200
  
  public func next() -> Self {
    let nextIndex = PlaceRadius.allCases.index(after: currentIndex)
    return PlaceRadius.allCases.indices.contains(nextIndex) ? .allCases[nextIndex] : .highest
  }
  
  public func previous() -> Self {
    let previousIndex = PlaceRadius.allCases.index(before: currentIndex)
    return PlaceRadius.allCases.indices.contains(previousIndex) ? .allCases[previousIndex] : .lowest
  }
  
  public static let lowest: Self = .allCases.first!
  public static let highest: Self = .allCases.last!
  
  
  var currentIndex: Self.AllCases.Index {
    Self.allCases.firstIndex(of: self)!
  }
}

public enum IntegrationSearchStatus: Equatable {
  case refreshing
  case notRefreshing
}
