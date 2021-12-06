import AppArchitecture
import ComposableArchitecture
import NonEmpty
import Types
import Utility

public struct AddOrderState: Equatable {
  public var id: ID? = nil
  public var createdAt: Date? = nil
//  public var location: Coordinate? = nil
//  public var address: Address? = nil
  public var destination: DestinationPickerState? = nil
  public var note: Note? = nil
  public var metadata: [Name: Contents] = []

  public init(id: ID?,
              createdAt: Date?,
              location: Coordinate?,
              address: Address?,
              note: Note?,
              metadata: [Name: Contents]) {
    self.id = id
    self.createdAt = createdAt
    self.location = location
    self.address = address
    self.note = note
    self.metadata = metadata
  }
  
  public init() {
  }
}

public enum AddOrderAction {
  case cancelAddOrder
  case changeName(String)
  case changeNote(String)
  case changeOrderId(Order.ID)
  case destinationPickerAction(DestinationPickerAction)
}

public let addOrderReducer = Reducer<AddOrderState, OrderAction, Empty> { state, action, _ in
  switch action {
    state.address = destination.address
  case let .changeNote(note):
    state.note = note
  case let .changeOrderId(id):
    state.id = id
  case let .changeName(name):
    state.metadata["name"] = name
  case .cancelAddOrder:
    state = AddOrderState()
  case .destinationPickerAction:
    break
  }
}

let destinationPickerOrderP = Reducer<
  AddOrderState,
  AddOrderAction,
  SystemEnvironment<DestinationEnvironment>
> = destinationPickerReducer.pullback(
  state: \.destination,
  action: addOrderDestinationoPrism,
  environment: identity
)


let addOrderDestinationoPrism = /AddOrderAction.destinationPickerAction

public let addOrderReducerP: Reducer<
  AddOrderState,
  AddOrderAction,
  SystemEnvironment<AddPlaceEnvironment>
> = .combine(
  destinationPickerPlaceP,
  addOrderReducer)
