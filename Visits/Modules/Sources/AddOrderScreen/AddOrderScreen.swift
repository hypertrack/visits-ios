import ComposableArchitecture
import SwiftUI


public struct AddOrderScreen: View {
  public struct State: Equatable {
    
    var pickingAddress: Bool
    
    var orderID: Order.ID?
    var orderNote: Order.Note?
    var destination: GeocodedResult?
    var name: String?
    
  
    public init(orderID: Order.ID?
                orderNote: Order.Note?
                address: Address?
                location: Coordinate?
                name: String?
                addressSearchResult: [Address]) {
      self.orderID = orderID
      self.orderNote = orderNote
      self.address = address
      self.location = location
      self.name = name
      self.addressSearchResult = addressSearchResult
    }
  }
  
  enum Action {
    case changeID(String)
    case changeNote(String)
    case changeName(String)
    case pickDestination(GeocodedResult?)
    
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
          state: constant(.init(geocoded: destination, places: viewStore.places)),
          action: 
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

