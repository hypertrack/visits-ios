import ComposableArchitecture
import SwiftUI
import UIKit
import Views

public struct VisitHeader: Equatable, Hashable, Identifiable {
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

public struct VisitsScreen: View {
  public struct State: Equatable {    public let pending: [VisitHeader]
    public let visited: [VisitHeader]
    public let completed: [VisitHeader]
    public let canceled: [VisitHeader]
    public let isNetworkAvailable: Bool
    public let refreshing: Bool
    public let showManualVisits: Bool
    
    public var noVisits: Bool {
      canceled.isEmpty && completed.isEmpty && pending.isEmpty && visited.isEmpty
    }
    
    public var totalVisits: Int {
      canceled.count + completed.count + pending.count + visited.count
    }
    
    public init(
      pending: [VisitHeader],
      visited: [VisitHeader],
      completed: [VisitHeader],
      canceled: [VisitHeader],
      isNetworkAvailable: Bool,
      refreshing: Bool,
      showManualVisits: Bool
    ) {
      self.pending = pending
      self.visited = visited
      self.completed = completed
      self.canceled = canceled
      self.isNetworkAvailable = isNetworkAvailable
      self.refreshing = refreshing
      self.showManualVisits = showManualVisits
    }
  }
  
  public enum Action: Equatable {
    case addVisitButtonTapped
    case clockOutButtonTapped
    case refreshButtonTapped
    case visitTapped(String)
  }
  
  @Environment(\.colorScheme) var colorScheme
  let store: Store<State, Action>
  
  public init(store: Store<State, Action>) {
    self.store = store
    UITableView.appearance().separatorInset = .zero
    UITableView.appearance().backgroundColor = .clear
    UITableView.appearance().separatorColor = UIColor(
      red: 199.0 / 255.0,
      green: 198.0 / 255.0,
      blue: 205.0 / 255.0,
      alpha: 1.0
    )
  }
  
  public var body: some View {
    WithViewStore(store) { viewStore in
      Navigation(
        title: "Visits",
        leading: {
          Button("Clock Out") {
            viewStore.send(.clockOutButtonTapped)
          }
          .font(.normalHighBold)
          .foregroundColor(colorScheme == .dark ? .white : .black)
          .frame(width: 110, height: 44, alignment: .leading)
        },
        trailing: {
          RefreshButton(state: viewStore.refreshing ? .refreshing : .enabled) {
            viewStore.send(.refreshButtonTapped)
          }
        },
        content: {
          ZStack {
            VStack(spacing: 0) {
              VisitStatus(
                text: viewStore.refreshing ? "Updating deliveries list." : viewStore.noVisits ? "No visits for today, tap refresh to update." : "You've made \(viewStore.completed.count + viewStore.canceled.count) out of \(viewStore.totalVisits) visits so far.",
                state: viewStore.noVisits ? .custom(color: Color.gray) : .visited
              )
              .padding(.top, 44)
              if !viewStore.isNetworkAvailable {
                VisitStatus(
                  text: "Network unavailable.",
                  state: .custom(color: Color.red)
                )
              }
              List {
                if !viewStore.pending.isEmpty {
                  visitSection(
                    for: .pending,
                    items: viewStore.pending
                  ) { viewStore.send(.visitTapped($0.id)) }
                }
                if !viewStore.visited.isEmpty {
                  visitSection(
                    for: .visited,
                    items: viewStore.visited
                  ) { viewStore.send(.visitTapped($0.id)) }
                }
                if !viewStore.completed.isEmpty {
                  visitSection(
                    for: .completed,
                    items: viewStore.completed
                  ) { viewStore.send(.visitTapped($0.id)) }
                }
                if !viewStore.canceled.isEmpty {
                  visitSection(
                    for: .canceled,
                    items: viewStore.canceled
                  ) { viewStore.send(.visitTapped($0.id)) }
                }
              }
              .modifier(AppBackground())
              .environment(\.horizontalSizeClass, .regular)
              .listStyle(GroupedListStyle())
            }
            .padding([.bottom], viewStore.showManualVisits ? 88 : 0)
            if viewStore.showManualVisits {
              VStack {
                Spacer()
                RoundedStack {
                  PrimaryButton(
                    variant: .normal(title: "Add Visit")
                  ) {
                    viewStore.send(.addVisitButtonTapped)
                  }
                  .padding([.trailing, .leading], 58)
                }
              }
            }
          }
        }
      )
      .modifier(AppBackground())
      .edgesIgnoringSafeArea(.bottom)
    }
  }
}

extension VisitsScreen {
  func visitSection(for status: Status, items: [VisitHeader], didSelect cell: @escaping (VisitHeader) -> Void) -> some View {
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
    VisitsScreen(
      store: .init(
        initialState: .init(
          pending: [.init(id: "1", title: "1301 Market St")],
          visited: [.init(id: "5", title: "2402 Davey St")],
          completed: [.init(id: "2", title: "275 Hayes St"), .init(id: "3", title: "Visit 12:30 AM — 01:15 PM")],
          canceled: [.init(id: "4", title: "4 Embracadero Ctr")],
          isNetworkAvailable: false,
          refreshing: false,
          showManualVisits: true
        ),
        reducer: .empty,
        environment: ()
      )
    )
  }
}
