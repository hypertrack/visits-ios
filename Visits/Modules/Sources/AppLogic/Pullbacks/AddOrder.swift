import AddPlaceLogic
import AppArchitecture
import ComposableArchitecture
import Utility
import Types
import AddOrderLogic


let addOrderP: Reducer<
  AppState,
  AppAction,
  SystemEnvironment<AppEnvironment>
> = addOrderReducerP.pullback(
  state: addOrderStateAffine,
  action: addOrderActionPrism,
  environment: toAddOrderEnvironment
)

private func toAddOrderEnvironment(_ e: SystemEnvironment<AppEnvironment>) -> SystemEnvironment<AddOrderEnvironment> {
  e.map { e in
    .init(
      autocompleteLocalSearch: e.maps.autocompleteLocalSearch,
      capture: e.errorReporting.capture,
      localSearch: e.maps.localSearch,
      reverseGeocode: e.maps.reverseGeocode,
      subscribeToLocalSearchCompletionResults: e.maps.subscribeToLocalSearchCompletionResults
    )
  }
}

private let addOrderStateAffine = /AppState.operational ** \.flow ** /AppFlow.main ** addOrderMainStateAffine

private let addOrderMainStateAffine = Affine<MainState, AddOrderState>(
  extract: { s in
    s.addOrderState
  },
  inject: { o in
     \.addOrderState *< o
  }
)

private let addOrderActionPrism = Prism<AppAction, AddOrderAction>(
  extract: { a in
    switch a {
    case .
    }
  },
  embed: { a in
    switch a {
      
    }
  }
)
