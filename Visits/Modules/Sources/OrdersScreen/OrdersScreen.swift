import ComposableArchitecture
import SwiftUI
import UIKit
import Views


public struct OrderHeader: Equatable, Hashable, Identifiable {
  public let id: String
  public let title: String
  
  public init(id: String, title: String) {
    self.id = id
    self.title = title
  }
}


enum Status: String {
  case pending = "⏳ Pending"
  case visited = "📦 Visited"
  case completed = "🏁 Completed"
  case canceled = "❌ Canceled"
}

public struct OrdersScreen: View {
  public struct State: Equatable {    public let pending: [OrderHeader]
    public let visited: [OrderHeader]
    public let completed: [OrderHeader]
    public let canceled: [OrderHeader]
    public let isNetworkAvailable: Bool
    public let refreshing: Bool
    public let deviceID: String
    public let publishableKey: String
    
    public var noOrders: Bool {
      canceled.isEmpty && completed.isEmpty && pending.isEmpty && visited.isEmpty
    }
    
    public var totalOrders: Int {
      canceled.count + completed.count + pending.count + visited.count
    }
    
    public init(
      pending: [OrderHeader],
      visited: [OrderHeader],
      completed: [OrderHeader],
      canceled: [OrderHeader],
      isNetworkAvailable: Bool,
      refreshing: Bool,
      deviceID: String,
      publishableKey: String
    ) {
      self.pending = pending
      self.visited = visited
      self.completed = completed
      self.canceled = canceled
      self.isNetworkAvailable = isNetworkAvailable
      self.refreshing = refreshing
      self.deviceID = deviceID
      self.publishableKey = publishableKey
    }
  }
  
  public enum Action: Equatable {
    case clockOutButtonTapped
    case refreshButtonTapped
    case orderTapped(String)
  }
  
  @Environment(\.colorScheme) var colorScheme
  let state: State
  let send: (Action) -> Void
  
  public init(
    state: State,
    send: @escaping (Action) -> Void
  ) {
    self.state = state
    self.send = send
  }
  
  public var body: some View {
    Navigation(
      title: "Orders",
      leading: {
        Button("Clock Out") {
          send(.clockOutButtonTapped)
        }
        .frame(width: 110, height: 44, alignment: .leading)
      },
      trailing: {
        RefreshButton(state: state.refreshing ? .refreshing : .enabled) {
          send(.refreshButtonTapped)
        }
      },
      content: {
        ZStack {
          VStack(spacing: 0) {
            VisitStatus(
              text: state.refreshing ? "Updating orders." : state.noOrders ? "No orders for today, tap refresh to update." : "You've completed \(state.completed.count + state.canceled.count) out of \(state.totalOrders) orders so far.",
              state: state.noOrders ? .custom(color: Color.gray) : .visited
            )
            .padding(.top, 44)
            if !state.isNetworkAvailable {
              VisitStatus(
                text: "Network unavailable.",
                state: .custom(color: Color.red)
              )
            }
            List {
              if !state.pending.isEmpty {
                orderSection(
                  for: .pending,
                  items: state.pending
                ) { send(.orderTapped($0.id)) }
              }
              if !state.visited.isEmpty {
                orderSection(
                  for: .visited,
                  items: state.visited
                ) { send(.orderTapped($0.id)) }
              }
              if !state.completed.isEmpty {
                orderSection(
                  for: .completed,
                  items: state.completed
                ) { send(.orderTapped($0.id)) }
              }
              if !state.canceled.isEmpty {
                orderSection(
                  for: .canceled,
                  items: state.canceled
                ) { send(.orderTapped($0.id)) }
              }
            }
            .modifier(AppBackground())
            .listStyle(GroupedListStyle())
            .environment(\.horizontalSizeClass, .regular)
          }
        }
      }
    )
    .modifier(AppBackground())
  }
}



extension OrdersScreen {
  func orderSection(for status: Status, items: [OrderHeader], didSelect cell: @escaping (OrderHeader) -> Void) -> some View {
    CustomSection(header: "\(status.rawValue)") {
      ForEach(items) { item in
        DeliveryCell(title: "\(item.title)") {
          cell(item)
        }
      }
    }
  }
}

struct VisitsScreen_Previews: PreviewProvider {
  static var previews: some View {
    OrdersScreen(
      state: .init(
        pending: [.init(id: "1", title: "1301 Market St")],
        visited: [.init(id: "5", title: "2402 Davey St")],
        completed: [.init(id: "2", title: "275 Hayes St"), .init(id: "3", title: "Visited at 12:30 AM — 01:15 PM")],
        canceled: [.init(id: "4", title: "4 Embracadero Ctr")],
        isNetworkAvailable: false,
        refreshing: false,
        deviceID: "blank",
        publishableKey: "blank"
      ),
      send: { _ in }
    )
    .previewScheme(.dark)
  }
}
