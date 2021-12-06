import AppArchitecture
import ComposableArchitecture
import NonEmpty
import Types
import Utility


// MARK: - Action

enum ChoosingAddressAction: Equatable {
  case cancelConfirmingLocation
  case localSearchCompletionResultsUpdated([LocalSearchCompletion])
  case localSearchUpdatedWithResult(MapPlace)
  case localSearchUpdatedWithResults(MapPlace, NonEmptyArray<MapPlace>)
  case localSearchUpdatedWithEmptyResult
  case localSearchUpdatedWithError(LocalSearchResult.Error)
  case localSearchUpdatedWithFatalError
  case selectAddress(LocalSearchCompletion)
  case updateAddressSearch(AddressSearch?)
}

let choosingAddressActionPrism = /DestinationPickerAction.addressAction

// MARK: - Reducer

let choosingAddressP: Reducer<
  DestinationPickerState,
  DestinationPickerAction,
  SystemEnvironment<DestinationEnvironment>
> = choosingAddressReducer.pullback(
  state: \.adding ** Optional.prism ** \.flow ** /AddPlaceFlow.choosingAddress,
  action: choosingAddressActionPrism,
  environment: identity
)

let choosingAddressReducer = Reducer<ChoosingAddress, ChoosingAddressAction, SystemEnvironment<DestinationEnvironment>> { state, action, environment in

  let autocompleteLocalSearch = autocompleteLocalSearch(
    als: environment.autocompleteLocalSearch,
    main: environment.mainQueue
  )
  let localSearch = localSearch(
    ls: environment.localSearch,
    main: environment.mainQueue
  )


  switch action {
  case .cancelConfirmingLocation:
    guard let s = state.flow *^? /ChoosingAddressFlow.confirming ** \.search
    else { return environment.capture("Trying to cancel confirming location when not confirming location").fireAndForget() }

    state.flow = .searching(.init(search: s))

    return .none
  case let .localSearchCompletionResultsUpdated(lss):
    guard let s = state.flow *^? /ChoosingAddressFlow.searching,
          s.selected == nil
    else { return .none }

    if s.search == nil  {
      state.results = []
    } else {
      state.results = lss
    }

    return .none
  case .localSearchUpdatedWithResult:
    return .none
  case let .localSearchUpdatedWithResults(mp, mps):
    guard let s = state.flow *^? /ChoosingAddressFlow.searching,
          let sel = s.selected,
          let se = s.search
    else { return .none }

    var locations = NonEmptyArray(mp)
    locations.append(contentsOf: mps)
    state.flow = .confirming(.init(search: se, selected: sel, locations: locations))

    return .none
  case .localSearchUpdatedWithEmptyResult,
       .localSearchUpdatedWithError,
       .localSearchUpdatedWithFatalError:
    guard let s = state.flow *^? /ChoosingAddressFlow.searching,
          s.selected != nil,
          s.search != nil
    else { return .none }

    state.flow = .searching(s |> \.selected *< nil)

    return .none
  case let .selectAddress(ls):
    guard let s = state.flow *^? /ChoosingAddressFlow.searching,
          s.search != nil
    else { return environment.capture("Trying to select an address when not in search by address view").fireAndForget() }

    state.flow = .searching(s |> \.selected *< ls)

    return localSearch(ls, state.currentLocation.rawValue)
  case let .updateAddressSearch(se):
    guard let s = state.flow *^? /ChoosingAddressFlow.searching
    else { return environment.capture("Updating address value when not in search by address view").fireAndForget() }

    switch se {
    case .none:
      state.flow = .searching(.init())
      state.results = []
    case let .some(se):
      state.flow = .searching(s |> \.search *< se)
    }

    return autocompleteLocalSearch(se, state.currentLocation.rawValue)
  }
}
