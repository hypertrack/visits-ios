import SwiftUI
import ComposableArchitecture
import Types
import OrdersListScreen
import Views
import NonEmpty
import OrderScreen

public struct TripScreen: View {
  public struct State {
    public let clockedIn: Bool
    public let trip: Trip?
    public let selectedOrderId: Order.ID?
    public let refreshing: Bool
    
    public init(
      clockedIn: Bool,
      trip: Trip?, 
      selected: Order.ID?, 
      refreshing: Bool
    ) {
      self.clockedIn = clockedIn
      self.trip = trip
      self.selectedOrderId = selected
      self.refreshing = refreshing
    }
  }
  
  public var state: State
  public let send: (OrdersListScreenAction) -> Void
  public let sendOrderAction: (OrderScreen.Action) -> Void

  public init(state: State,
              send: @escaping (OrdersListScreenAction) -> Void,
              sendOrderAction: @escaping (OrderScreen.Action) -> Void) {
    self.state = state
    self.send = send
    self.sendOrderAction = sendOrderAction
  }
  
  public var body: some View {
    NavigationView {
      VStack {
        if let trip = state.trip {
          OrdersListScreen(
            state: .init(
              orders: trip.orders,
              selected: state.selectedOrderId
            ),
            send: send,
            sendOrderAction: sendOrderAction
          ) {
            ContentCell(
              title: "ID",
              subTitle: trip.id.string,
              leadingPadding: 24,
              copyTextPressed
            )
            ForEach(metadata.sorted(by:>), id: \.key) { key, value in
              ContentCell(
                title: key,
                subTitle: value,
                leadingPadding: 24,
                copyTextPressed
              )
            }
            .padding(.top, 8)
          }
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
          Button(action: { 
            send(.clockInToggleTapped) 
          }) {
            Text(state.clockedIn ? "Clock Out" : "Clock In")
          }
        }
      }
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }
  
  private var copyTextPressed: (String) -> Void {
    return {str in
      if let na = NonEmptyString(rawValue: str) {
        sendOrderAction(.copyTextPressed(na))
      }
    }
  }
  
  private var metadata: [String: String] {
    let keysAndValues = state.trip?.metadata
      .map({ $0 })
      .sorted(by: \.key)
      .map({ ("\($0)", "\($1)") })
    return Dictionary(uniqueKeysWithValues: keysAndValues ?? [])
  }
}

