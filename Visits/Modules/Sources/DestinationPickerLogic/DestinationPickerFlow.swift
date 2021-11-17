// MARK: - Environment

public struct DestinationEnvironment {
  public var autocompleteLocalSearch: (AddressSearch?, Coordinate) -> Effect<Never, Never>
  public var capture: (CaptureMessage) -> Effect<Never, Never>
  public var localSearch: (LocalSearchCompletion, Coordinate) -> Effect<LocalSearchResult, Never>
  public var reverseGeocode: (Coordinate) -> Effect<GeocodedResult, Never>
  public var subscribeToLocalSearchCompletionResults: () -> Effect<[LocalSearchCompletion], Never>
  
  public init(
    autocompleteLocalSearch: @escaping (AddressSearch?, Coordinate) -> Effect<Never, Never>,
    capture: @escaping (CaptureMessage) -> Effect<Never, Never>,
    localSearch: @escaping (LocalSearchCompletion, Coordinate) -> Effect<LocalSearchResult, Never>,
    reverseGeocode: @escaping (Coordinate) -> Effect<GeocodedResult, Never>,
    subscribeToLocalSearchCompletionResults: @escaping () -> Effect<[LocalSearchCompletion], Never>
  ) {
    self.autocompleteLocalSearch = autocompleteLocalSearch
    self.capture = capture
    self.localSearch = localSearch
    self.reverseGeocode = reverseGeocode
    self.subscribeToLocalSearchCompletionResults = subscribeToLocalSearchCompletionResults
  }
}

