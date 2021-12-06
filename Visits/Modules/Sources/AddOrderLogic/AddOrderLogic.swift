import AppArchitecture
import ComposableArchitecture
import NonEmpty
import Types
import Utility
import DestinationPickerLogic

public struct AddOrderState: Equatable {
  public var id: Order.ID? = nil
  public var createdAt: Date? = nil
//  public var location: Coordinate? = nil
//  public var address: Address? = nil
  public var destination: DestinationPickerState? = nil
  public var note: Order.Note? = nil
  public var metadata: [Name: Order.Contents] = [:]

  public init(id: Order.ID?,
              createdAt: Date?,
              location: Coordinate?,
              address: Address?,
              note: Order.Note?,
              metadata: [Name: Order.Contents]) {
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
  case orderCreatedWithSuccess(Trip)
  case orderCreatedWithFailure(APIError<Token.Expired>)

}

public let addOrderReducer = Reducer<AddOrderState, OrderAction, Empty> { state, action, _ in
  switch action {
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
  case .orderCreatedWithSuccess:
    state.id = nil
    state.createdAt = nil
    state.destination = nil
    state.note = nil
    state.metadata = [:]
  case .orderCreatedWithFailure:
    break
  }
  return .none
}

let destinationPickerOrderP: Reducer<
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
  SystemEnvironment<AddOrderEnvironment>
> = .combine(
  destinationPickerPlaceP,
  addOrderReducer)
