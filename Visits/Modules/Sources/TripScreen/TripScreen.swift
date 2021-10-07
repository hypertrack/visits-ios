import SwiftUI
import ComposableArchitecture
import Types
import OrdersListScreen
import Views
import NonEmpty
import OrderScreen

public struct TripScreen: View {
  public struct State {
    public let trip: Trip?
    public let selectedOrderId: Order.ID?
    public let refreshing: Bool
    
    public init(trip: Trip?, selected: Order.ID?, refreshing: Bool) {
      self.trip = trip
      self.selectedOrderId = selected
      self.refreshing = refreshing
    }
  }
  
  public var state: State
  public let send: (OrdersListScreen.Action) -> Void
  public let sendOrderAction: (OrderScreen.Action) -> Void

  public init(state: State,
              send: @escaping (OrdersListScreen.Action) -> Void,
              sendOrderAction: @escaping (OrderScreen.Action) -> Void) {
    self.state = state
    self.send = send
    self.sendOrderAction = sendOrderAction
  }
  
  public var body: some View {
    NavigationView {
      VStack {
        if let trip = state.trip {
          ContentCell(title: "ID",
                      subTitle: trip.id.rawValue,
                      leadingPadding: 24,
                      isCopyButtonEnabled: true) { str in
            if let na = NonEmptyString(rawValue: str) {
              sendOrderAction(.copyTextPressed(na))
            }
          }
          ContentCell(title: "Created",
                      subTitle: "Trip @ \(DateFormatter.stringTime(trip.createdAt))",
                      leadingPadding: 24,
                      isCopyButtonEnabled: false)
          OrdersListScreen(state: .init(orders: trip.orders,
                                        selected: state.selectedOrderId),
                           send: send,
                           sendOrderAction: sendOrderAction)
        } else {
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

    }
    .navigationViewStyle(StackNavigationViewStyle())
  }
}

