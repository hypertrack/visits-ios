import AddPlaceLogic
import AppArchitecture
import ComposableArchitecture
import Utility
import Types
import AddOrderLogic


struct AddOrder
  public enum Flow: Equatable {
    case order(OrderRequest)
    case trip(TripRequest)
  }
  public var addOrderFlow: Flow
  public var destinationPickerFlow: DestinationPickerState.Flow?

  public init(addOrderFlow: Flow, destinationPickerFlow: DestinationPickerState.Flow?) {
    self.addOrderFlow = addOrderFlow
    self.destinationPickerFlow = destinationPickerFlow
  }
}


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
    switch s.addOrder.addOrderFlow {
    case let .order(order):
      let dst: DestinationPickerState?
      if let flow = s.destinationPickerFlow {
        let place: GeocodedResult?
        if let location = order.location {
          place = GeocodedResult(coordinate: location, address: order.address ? order.address : .none)
        }
        dst = DestinationPickerState(flow: flow, place: place)
      }
      return AddOrderState(orderId: order.id, createdAt: order.createdAt, destination: dst, note: order.note, metadata: order.metadata)
    }
  },
  inject: { o in
    let addOrder: AddOrder
    let orderRequest = OrderRequest(id: o.orderId, createdAt: o.createdAt, location: o.location, address: o.address, note: o.note, metadata: o.metadata)
    if let tripId = o.tripId {
      let tripRequest = TripRequest(id: tripId, orderRequest: orderRequest)
      addOrder = AddOrder(addOrderFlow: .trip(tripRequest), o.destination?.flow)
    } else {
      addOrder = AddOrder(addOrderFlow: .order(orderRequest), o.destination?.flow)
    }
  return addOrder
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
