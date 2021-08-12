import ComposableArchitecture
import Types


func reverseGeocode<Action>(
  rge: @escaping (Coordinate) -> Effect<GeocodedResult, Never>,
  toA: @escaping (GeocodedResult) -> Action,
  main: AnySchedulerOf<DispatchQueue>
) -> (Coordinate) -> Effect<Action, Never> {
  { c in
    rge(c)
      .map(toA)
      .receive(on: main)
      .eraseToEffect()
  }
}

struct LocalSearchCompletionResultsSubscriptionID: Hashable {}

func subscribeToLocalSearchCompletionResults(
  s: @escaping () -> Effect<[LocalSearchCompletion], Never>,
  main: AnySchedulerOf<DispatchQueue>
) -> Effect<FlowSwitchingAction, Never> {
  s()
    .map(FlowSwitchingAction.localSearchCompletionResultsUpdated)
    .receive(on: main)
    .eraseToEffect()
    .cancellable(id: LocalSearchCompletionResultsSubscriptionID(), cancelInFlight: true)
}

func autocompleteLocalSearch(
  als: @escaping (AddressSearch?, Coordinate) -> Effect<Never, Never>,
  main: AnySchedulerOf<DispatchQueue>
) -> (AddressSearch?, Coordinate) -> Effect<ChoosingAddressAction, Never> {
  { st, c in
    als(st, c)
      .fireAndForget()
      .receive(on: main)
      .eraseToEffect()
  }
}

struct LocalSearchID: Hashable {}

func localSearch(
  ls: @escaping (LocalSearchCompletion, Coordinate) -> Effect<LocalSearchResult, Never>,
  main: AnySchedulerOf<DispatchQueue>
) -> (LocalSearchCompletion, Coordinate) -> Effect<ChoosingAddressAction, Never> {
  { lsc, c in
    ls(lsc, c)
      .map { r in
        switch r {
        case let .result(mp):       return .localSearchUpdatedWithResult(mp)
        case let .results(mp, mps): return .localSearchUpdatedWithResults(mp, mps)
        case     .empty:            return .localSearchUpdatedWithEmptyResult
        case let .error(e):         return .localSearchUpdatedWithError(e)
        case     .fatalError:       return .localSearchUpdatedWithFatalError
        }
      }
      .receive(on: main)
      .eraseToEffect()
      .cancellable(id: LocalSearchID(), cancelInFlight: true)
  }
}
