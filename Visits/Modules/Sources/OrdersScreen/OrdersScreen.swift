import ComposableArchitecture
import SwiftUI
import Types
import UIKit
import Views


enum Status: String {
  case pending = "⏳ Pending"
  case visited = "📦 Visited"
  case completed = "🏁 Completed"
  
  case canceled = "❌ Canceled"
  
  case snoozed = "⏸ Snoozed"
}

public struct OrdersScreen: View {
  public struct State: Equatable {
    public let orders: Set<Order>
    public let refreshing: Bool
    
    public init(
      orders: Set<Order>,
      refreshing: Bool
    ) {
      self.orders = orders
      self.refreshing = refreshing
    }
  }
  
  public enum Action: Equatable {
    case clockOutButtonTapped
    case refreshButtonTapped
    case orderTapped(Order)
  }
  
  @Environment(\.colorScheme) var colorScheme
  let state: State
  let send: (Action) -> Void
  
  var pending: [Order] {
    state.orders.filter {
      switch ($0.status, $0.visited) {
      case (.ongoing, .none),
        (.cancelling, .none),
        (.completing, .none): return true
      default:                return false
      }
    }
    .sorted(by: \.id)
  }
  var visited: [Order] {
    state.orders.filter {
      switch ($0.status, $0.visited) {
      case (.ongoing, .some),
        (.cancelling, .some),
        (.completing, .some): return true
      default:                return false
      }
    }
    .sorted(by: \.id)
  }
  var completed: [Order] {
    state.orders.filter {
      guard case .completed = $0.status else { return false }
      return true
    }
    .sorted(by: \.id)
  }
  var canceled: [Order] {
    state.orders.filter {
      guard case .cancelled = $0.status else { return false }
      return true
    }
    .sorted(by: \.id)
  }
  var snoozed: [Order] {
    state.orders.filter {
      guard case .disabled = $0.status else { return false }
      return true
    }
    .sorted(by: \.id)
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
        RefreshButton(state: state.refreshing ? .refreshing : .enabled) {
          send(.refreshButtonTapped)
        }
      },
      content: {
        ZStack {
          VStack(spacing: 0) {
            VisitStatus(
              text: state.refreshing ? "Updating orders." : state.orders.isEmpty ? "No orders for today, tap refresh to update." : "You've completed \(completed.count + canceled.count) out of \(state.orders.count) orders so far.",
              state: state.orders.isEmpty ? .custom(color: Color.gray) : .visited
            )
            .padding(.top, 44)
            List {
              if !pending.isEmpty {
                orderSection(
                  for: .pending,
                  order: pending
                ) { send(.orderTapped($0)) }
              }
              if !visited.isEmpty {
                orderSection(
                  for: .visited,
                  order: visited
                ) { send(.orderTapped($0)) }
              }
              if !completed.isEmpty {
                orderSection(
                  for: .completed,
                  order: completed
                ) { send(.orderTapped($0)) }
              }
              if !canceled.isEmpty {
                orderSection(
                  for: .canceled,
                  order: canceled
                ) { send(.orderTapped($0)) }
              }
              if !snoozed.isEmpty {
                orderSection(
                  for: .snoozed,
                  order: snoozed
                ) { send(.orderTapped($0)) }
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
  func orderSection(for status: Status, order: [Order], didSelect cell: @escaping (Order) -> Void) -> some View {
    CustomSection(header: "\(status.rawValue)") {
      ForEach(order) { order in
        DeliveryCell(title: "\(orderTitle(from: order))") {
          cell(order)
        }
      }
    }
  }
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

extension Sequence {
  func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
    return sorted { a, b in
      return a[keyPath: keyPath] < b[keyPath: keyPath]
    }
  }
}

//struct VisitsScreen_Previews: PreviewProvider {
//  static var previews: some View {
//    OrdersScreen(
//      state: .init(
//        orders: [entered, checkedOut1, checkedOut2, checkedOut3],
//        refreshing: .refreshingOrders
//      ),
//      send: { _ in }
//    )
//    .previewScheme(.dark)
//  }
//}
//
//let entered = Order(
//  id: Order.ID(rawValue: "ID7"),
//  createdAt: Calendar.current.date(bySettingHour: 9, minute: 40, second: 0, of: Date())!,
//  location: Coordinate(latitude: 37.778655, longitude: -122.422231)!,
//  geotagSent: .entered(Date()),
//  noteFieldFocused: false,
//  address: .init(
//    street: Street(rawValue: "333 Fulton St"),
//    fullAddress: FullAddress(rawValue: "333 Fulton St, San Francisco, CA  94102, United States")
//  )
//)
//
//let checkedOut1 = Order(
//  id: Order.ID(rawValue: "ID1"),
//  createdAt: Calendar.current.date(bySettingHour: 9, minute: 35, second: 0, of: Date())!,
//  location: Coordinate(latitude: 37.776692, longitude: -122.416557)!,
//  geotagSent: .checkedOut(.none, Date()),
//  noteFieldFocused: false,
//  address: .init(
//    street: Street(rawValue: "1301 Market St"),
//    fullAddress: FullAddress(rawValue: "Market Square, 1301 Market St, San Francisco, CA  94103, United States")
//  )
//)
//
//let checkedOut2 = Order(
//  id: Order.ID(rawValue: "ID2"),
//  createdAt: Calendar.current.date(bySettingHour: 9, minute: 36, second: 0, of: Date())!,
//  location: Coordinate(latitude: 37.776753, longitude: -122.420371)!,
//  geotagSent: .checkedOut(.none, Date()),
//  noteFieldFocused: false,
//  address: .init(
//    street: Street(rawValue: "275 Hayes St"),
//    fullAddress: FullAddress(rawValue: "275 Hayes St, San Francisco, CA  94102, United States")
//  )
//)
//
//let checkedOut3 = Order(
//  id: Order.ID(rawValue: "ID5"),
//  createdAt: Calendar.current.date(bySettingHour: 9, minute: 38, second: 0, of: Date())!,
//  location: Coordinate(latitude: 37.783049, longitude: -122.418242)!,
//  geotagSent: .checkedOut(.none, Date()),
//  noteFieldFocused: false,
//  address: .init(
//    street: Street(rawValue: "601 Eddy St"),
//    fullAddress: FullAddress(rawValue: "601 Eddy St, San Francisco, CA  94109, United States")
//  )
//)
