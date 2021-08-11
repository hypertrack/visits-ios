import ComposableArchitecture
import Types


public struct MapDependency {
  public var autocompleteLocalSearch: (Street?, Coordinate) -> Effect<Never, Never>
  public var localSearch: (LocalSearchCompletion, Coordinate) -> Effect<LocalSearchResult, Never>
  public var openMap: (Coordinate, Address) -> Effect<Never, Never>
  public var reverseGeocode: (Coordinate) -> Effect<GeocodedResult, Never>
  public var subscribeToLocalSearchCompletionResults: () -> Effect<[LocalSearchCompletion], Never>
  
  
  public init(
    autocompleteLocalSearch: @escaping (Street?, Coordinate) -> Effect<Never, Never>,
    localSearch: @escaping (LocalSearchCompletion, Coordinate) -> Effect<LocalSearchResult, Never>,
    openMap: @escaping (Coordinate, Address) -> Effect<Never, Never>,
    reverseGeocode: @escaping (Coordinate) -> Effect<GeocodedResult, Never>,
    subscribeToLocalSearchCompletionResults: @escaping () -> Effect<[LocalSearchCompletion], Never>
  ) {
    self.autocompleteLocalSearch = autocompleteLocalSearch
    self.localSearch = localSearch
    self.openMap = openMap
    self.reverseGeocode = reverseGeocode
    self.subscribeToLocalSearchCompletionResults = subscribeToLocalSearchCompletionResults
  }
}
