import ComposableArchitecture
import SwiftUI
import UIKit
import Views
import Types
import OrderScreen
import Utility
import IdentifiedCollections


public enum OrdersListScreenAction: Equatable {
  case clockOutButtonTapped
  case refreshButtonTapped
  case orderTapped(Order.ID?)
  case addOrderTapped
}

public struct OrdersListScreen<Content: View>: View {
  public struct State {
    public let orders: IdentifiedArrayOf<Order>
    public let selected: Order.ID?
    
    public init(orders: IdentifiedArrayOf<Order>, selected: Order.ID?) {
      self.orders = orders
      self.selected = selected
    }
  }
    
  let state: State
  let send: (OrdersListScreenAction) -> Void
  let sendOrderAction: (OrderScreen.Action) -> Void
  let content: () -> Content
  
  public init(
    state: State,
    send: @escaping (OrdersListScreenAction) -> Void,
    sendOrderAction: @escaping (OrderScreen.Action) -> Void,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.state = state
    self.send = send
    self.sendOrderAction = sendOrderAction
    self.content = content
  }
  
  var navigationLink: NavigationLink<EmptyView, OrderScreen>? {
    guard let selected = state.selected,
            let order = state.orders[safeId: state.selected] else { return nil }
    
    return NavigationLink(
      destination: OrderScreen(
        state: order,
        send: { sendOrderAction($0) }
      ),
      tag: selected,
      selection: .init(
        get: { state.selected },
        set: { send(.orderTapped($0)) }
      )
    ) {
      EmptyView()
    }
  }
  
  public var body: some View {
    ZStack {
      navigationLink
      List {
        content()
        ForEach(ordersSortedLikeATaskManager(state.orders.elements)) { order in
          Button {
            send(.orderTapped(order.id))
          } label: {
            OrderCell(order: order)
          }
        }
      }
      .listStyle(PlainListStyle())
    }
  }
}

private extension Order {
  var sortableName: String {
    return name?.rawValue ?? ""
  }
}

extension Order.Status {
  var isOngoing: Bool {
    if case .ongoing = self {
      return true
    }
    return false
  }
}

private func ordersSortedLikeATaskManager(_ orders: [Order]) -> [Order] {
  var ongoing: [Order] = []
  var actedUpon: [Order] = []

  for order in orders {
    if order.status.isOngoing {
      ongoing.append(order)
    } else {
      actedUpon.append(order)
    }
  }
  return ongoing + actedUpon
}
