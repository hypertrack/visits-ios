import AppArchitecture
import ComposableArchitecture
import NonEmpty
import Types
import Utility

public struct DestinationPickerState: Equatable {
  
  public enum Flow: Equatable {
    case address
    case map
  }
  
  public var flow: Flow
  public var place: GeoCodedResult?
}

public enum DestinationPickerAction {
  case changeFlow(DestinationPickerState.Flow)
  case pickAddress(Address)
  case pickCoordinate(Coordinate)
  case addressAction(ChoosingAddressAction)
  case coordinateAction(ChoosingCoordinateAction)
}

public let destinationPickerReducer =
  (choosingAddressP,
  choosingCoordinateP,
  destintionPickerFlowP)
    .combine)
