import ComposableArchitecture
import SwiftUI
import UIKit
import Views
import Types
import OrderScreen


public struct OrdersListScreen: View {
  
  public enum Action: Equatable {
    case clockOutButtonTapped
    case refreshButtonTapped
    case orderTapped(Order?)
  }
  
  public struct State {
    public let orders: [Order]
    public let selected: Order?
    public let refreshing: Bool
    
    public init(orders: [Order], selected: Order?, refreshing: Bool) {
      self.orders = orders
      self.selected = selected
      self.refreshing = refreshing
    }
  }
  
  let state: State
  let send: (Action) -> Void
  let sendOrderAction: (OrderScreen.Action) -> Void
  
  public init(state: State,
              send: @escaping (Action) -> Void,
              sendOrderAction: @escaping (OrderScreen.Action) -> Void) {
    self.state = state
    self.send = send
    self.sendOrderAction = sendOrderAction
  }
  
  var navigationLink: NavigationLink<EmptyView, OrderScreen>? {
    guard let order = state.selected else { return nil }
    
    return NavigationLink(
      destination: OrderScreen(
        state: order,
        send: { sendOrderAction($0) }
      ),
      tag:  order,
      selection: .init(
        get: { state.selected },
        set: { send(.orderTapped($0)) }
      )
    ) {
      EmptyView()
    }
  }
  
  public var body: some View {
    NavigationView {
      ZStack {
        navigationLink
        List(state.orders.sorted(by: \.sortableName)) { order in
          Button {
            send(.orderTapped(order))
          } label: {
            OrderCell(order: order)
          }
        }
        .listStyle(PlainListStyle())
        if state.orders.isEmpty {
          Text("No orders yet")
            .font(.title)
            .foregroundColor(Color(.secondaryLabel))
            .fontWeight(.bold)
        }
      }
      .navigationBarTitle(Text("Orders"), displayMode: .automatic)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          RefreshButton(state: state.refreshing ? .refreshing : .enabled) {
            send(.refreshButtonTapped)
          }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: { send(.clockOutButtonTapped) }) {
            Text("Clock Out")
          }
        }
      }
    }.navigationViewStyle(StackNavigationViewStyle())
  }
  
}

private extension Order {
  var sortableName: String {
    return name?.rawValue ?? ""
  }
}
