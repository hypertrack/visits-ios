import ComposableArchitecture
import SwiftUI
import DestinationPickerScreen
import Types

public struct AddOrderScreen: View {
  public struct State: Equatable {
    
    var pickingAddress: Bool
    
    var orderRequest: OrderRequest?
    
    public init(orderRequest: OrderRequest?) {
//      self.orderID = orderID
//      self.orderNote = orderNote
//      self.destination = destination
//      self.name = name
//      self.addressSearchResult = addressSearchResult
      self.orderRequest = orderRequest
    }
  }
  
  public enum Action {
    case changeID(String)
    case changeNote(String)
    case changeName(String)
//    case pickDestination(GeocodedResult?)
    case destinationPickerAction(DestinationPickerView.Action)
    
    case addOrder(Order)
  }
  
  let store: Store<State, Action>
  
  public init(store: Store<State, Action>) {
    self.store = store
  }
  
  public var body: some View {
    WithViewStore(store) { viewStore in
      if store.state.pickingAddress {
        DestinationPickerView(store: store.scope(
          state: .constant(.init(geocoded: orderRequest.destination, places: viewStore.places)),
          action: (/Action.destinationPickerAction).embed
        ))
      } else {
        VStack {
          MapDetailView(
            object: .place(
              .init(
                id: "Temp",
                address: .none,
                createdAt: .init(rawValue: Date()),
                shape: .circle(
                  .init(
                    center: viewStore.state.location,
                    radius: 42
                  )
                ),
                visits: []
              )
            )
          )
          ContentCell(
            title: "Address",
            subTitle: viewStore.state.address,
            { store.send(.pickDestination(viewStore.state.destination)) }
          )
          EditContentCell(
            title: "Order ID",
            subTitle: viewStore.state.orderID,
            { str in store.send(.changeID(str)) }
          )
          EditContentCell(
            title: "Name",
            subTitle: viewStore.state.name,
            { str in store.send(.changeName(str)) }
          )
          EditContentCell(
            title: "Note",
            subTitle: viewStore.state.orderNote,
            { str in store.send(.changeNote(str)) }
          )
        }
      }
    }
  }
}

// MARK: - Styles

fileprivate extension EditContentCell {
  init(title: String, subtitle: String, _ onEditAction: @escaping () -> Void = {}) {
    init(title: title,
         subTitle: subtitle,
         leadingPadding: 24,
         onEditAction)
      .padding(.top, 8)
  }
}
