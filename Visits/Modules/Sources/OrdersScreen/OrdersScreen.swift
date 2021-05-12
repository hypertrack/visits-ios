import ComposableArchitecture
import SwiftUI
import Types
import UIKit
import Views


struct OrderHeader: Equatable, Hashable, Identifiable {
  let id: String
  let title: String
  
  init(id: String, title: String) {
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
  public struct State: Equatable {
    public let orders: Set<Order>
    public let refreshing: Refreshing.Orders
    
    public init(
      orders: Set<Order>,
      refreshing: Refreshing.Orders
    ) {
      self.orders = orders
      self.refreshing = refreshing
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
  
  var pending: [OrderHeader] {
    orderHeaders(from: state.orders).0
  }
  var visited: [OrderHeader] {
    orderHeaders(from: state.orders).1
  }
  var completed: [OrderHeader] {
    orderHeaders(from: state.orders).2
  }
  var canceled: [OrderHeader] {
    orderHeaders(from: state.orders).3
  }
  var isNetworkAvailable: Bool = true
  
  var noOrders: Bool {
    canceled.isEmpty && completed.isEmpty && pending.isEmpty && visited.isEmpty
  }
  
  var totalOrders: Int {
    canceled.count + completed.count + pending.count + visited.count
  }
  
  var refreshing: Bool {
    state.refreshing == .refreshingOrders
  }
  
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
        RefreshButton(state: refreshing ? .refreshing : .enabled) {
          send(.refreshButtonTapped)
        }
      },
      content: {
        ZStack {
          VStack(spacing: 0) {
            VisitStatus(
              text: refreshing ? "Updating orders." : noOrders ? "No orders for today, tap refresh to update." : "You've completed \(completed.count + canceled.count) out of \(totalOrders) orders so far.",
              state: noOrders ? .custom(color: Color.gray) : .visited
            )
            .padding(.top, 44)
            if !isNetworkAvailable {
              VisitStatus(
                text: "Network unavailable.",
                state: .custom(color: Color.red)
              )
            }
            List {
              if !pending.isEmpty {
                orderSection(
                  for: .pending,
                  items: pending
                ) { send(.orderTapped($0.id)) }
              }
              if !visited.isEmpty {
                orderSection(
                  for: .visited,
                  items: visited
                ) { send(.orderTapped($0.id)) }
              }
              if !completed.isEmpty {
                orderSection(
                  for: .completed,
                  items: completed
                ) { send(.orderTapped($0.id)) }
              }
              if !canceled.isEmpty {
                orderSection(
                  for: .canceled,
                  items: canceled
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

func orderHeaders(from os: Set<Order>) -> ([OrderHeader], [OrderHeader], [OrderHeader], [OrderHeader]) {
  var pending: [(Date, OrderHeader)] = []
  var visited: [(Date, OrderHeader)] = []
  var completed: [(Date, OrderHeader)] = []
  var canceled: [(Date, OrderHeader)] = []
  
  for v in os {
    let t = orderTitle(from: v)
    
    let h = OrderHeader(id: v.id.string, title: t)
    switch v.geotagSent {
    case .notSent, .pickedUp: pending.append((v.createdAt, h))
    case .entered, .visited:  visited.append((v.createdAt, h))
    case .checkedOut:         completed.append((v.createdAt, h))
    case .cancelled:          canceled.append((v.createdAt, h))
    }
  }
  return (
    pending.sorted(by: sortHeaders).map(\.1),
    visited.sorted(by: sortHeaders).map(\.1),
    completed.sorted(by: sortHeaders).map(\.1),
    canceled.sorted(by: sortHeaders).map(\.1)
  )
}

func orderTitle(from v: Order) -> String {
  switch v.address.anyAddressStreetBias {
  case     .none:    return "Order @ \(DateFormatter.stringDate(v.createdAt))"
  case let .some(a): return a.rawValue
  }
}

extension DateFormatter {
  static func stringDate(_ date: Date) -> String {
    let dateFormat = DateFormatter()
    dateFormat.locale = Locale(identifier: "en_US_POSIX")
    dateFormat.dateFormat = "h:mm a"
    return dateFormat.string(from: date)
  }
}

func sortHeaders(_ left: (date: Date, order: OrderHeader), _ right: (date: Date, order: OrderHeader)) -> Bool {
  left.date > right.date
}

struct VisitsScreen_Previews: PreviewProvider {
  static var previews: some View {
    OrdersScreen(
      state: .init(
        orders: [entered, checkedOut1, checkedOut2, checkedOut3],
        refreshing: .refreshingOrders
      ),
      send: { _ in }
    )
    .previewScheme(.dark)
  }
}

let entered = Order(
  id: Order.ID(rawValue: "ID7"),
  createdAt: Calendar.current.date(bySettingHour: 9, minute: 40, second: 0, of: Date())!,
  source: .trip,
  location: Coordinate(latitude: 37.778655, longitude: -122.422231)!,
  geotagSent: .entered(Date()),
  noteFieldFocused: false,
  address: .init(
    street: Street(rawValue: "333 Fulton St"),
    fullAddress: FullAddress(rawValue: "333 Fulton St, San Francisco, CA  94102, United States")
  )
)

let checkedOut1 = Order(
  id: Order.ID(rawValue: "ID1"),
  createdAt: Calendar.current.date(bySettingHour: 9, minute: 35, second: 0, of: Date())!,
  source: .trip,
  location: Coordinate(latitude: 37.776692, longitude: -122.416557)!,
  geotagSent: .checkedOut(.none, Date()),
  noteFieldFocused: false,
  address: .init(
    street: Street(rawValue: "1301 Market St"),
    fullAddress: FullAddress(rawValue: "Market Square, 1301 Market St, San Francisco, CA  94103, United States")
  )
)

let checkedOut2 = Order(
  id: Order.ID(rawValue: "ID2"),
  createdAt: Calendar.current.date(bySettingHour: 9, minute: 36, second: 0, of: Date())!,
  source: .trip,
  location: Coordinate(latitude: 37.776753, longitude: -122.420371)!,
  geotagSent: .checkedOut(.none, Date()),
  noteFieldFocused: false,
  address: .init(
    street: Street(rawValue: "275 Hayes St"),
    fullAddress: FullAddress(rawValue: "275 Hayes St, San Francisco, CA  94102, United States")
  )
)

let checkedOut3 = Order(
  id: Order.ID(rawValue: "ID5"),
  createdAt: Calendar.current.date(bySettingHour: 9, minute: 38, second: 0, of: Date())!,
  source: .trip,
  location: Coordinate(latitude: 37.783049, longitude: -122.418242)!,
  geotagSent: .checkedOut(.none, Date()),
  noteFieldFocused: false,
  address: .init(
    street: Street(rawValue: "601 Eddy St"),
    fullAddress: FullAddress(rawValue: "601 Eddy St, San Francisco, CA  94109, United States")
  )
)
