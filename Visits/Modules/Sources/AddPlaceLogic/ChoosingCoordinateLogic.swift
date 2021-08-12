import AppArchitecture
import ComposableArchitecture
import Types
import Utility


// MARK: - Action

enum ChoosingCoordinateAction: Equatable {
  case liftedAddPlaceCoordinatePin
  case reverseGeocoded(GeocodedResult)
  case updatedAddPlaceCoordinate(Coordinate)
}

let choosingCoordinateActionPrism = Prism<AddPlaceAction, ChoosingCoordinateAction>(
  extract: { a in
    switch a {
    case     .liftedAddPlaceCoordinatePin:  return .liftedAddPlaceCoordinatePin
    case let .reverseGeocoded(gr):          return .reverseGeocoded(gr)
    case let .updatedAddPlaceCoordinate(c): return .updatedAddPlaceCoordinate(c)
    default:                                return nil
    }
  },
  embed: { a in
    switch a {
    case     .liftedAddPlaceCoordinatePin: return  .liftedAddPlaceCoordinatePin
    case let .reverseGeocoded(gr):         return  .reverseGeocoded(gr)
    case let .updatedAddPlaceCoordinate(c): return .updatedAddPlaceCoordinate(c)
    }
  }
)

// MARK: - Reducer

let choosingCoordinateP: Reducer<
  AddPlaceState,
  AddPlaceAction,
  SystemEnvironment<AddPlaceEnvironment>
> = choosingCoordinateReducer.pullback(
  state: \.adding ** Optional.prism ** \.flow ** /AddPlaceFlow.choosingCoordinate,
  action: choosingCoordinateActionPrism,
  environment: identity
)

let choosingCoordinateReducer = Reducer<GeocodedResult?, ChoosingCoordinateAction, SystemEnvironment<AddPlaceEnvironment>> { state, action, environment in
  let reverseGeocode = reverseGeocode(
    rge: environment.reverseGeocode,
    toA: ChoosingCoordinateAction.reverseGeocoded,
    main: environment.mainQueue
  )

  switch action {
  case .liftedAddPlaceCoordinatePin:

    state = nil

    return .none
  case let .reverseGeocoded(gr):
    guard gr.coordinate == state?.coordinate else { return .none}

    state = gr

    return .none
  case let .updatedAddPlaceCoordinate(c):

    state = .init(coordinate: c)

    return reverseGeocode(c)
  }
}
