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
    public let deviceID: String
    public let publishableKey: String
    
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
      showManualVisits: Bool,
      deviceID: String,
      publishableKey: String
    ) {
      self.pending = pending
      self.visited = visited
      self.completed = completed
      self.canceled = canceled
      self.isNetworkAvailable = isNetworkAvailable
      self.refreshing = refreshing
      self.showManualVisits = showManualVisits
      self.deviceID = deviceID
      self.publishableKey = publishableKey
    }
  }
  
  public enum Action: Equatable {
    case addVisitButtonTapped
    case clockOutButtonTapped
    case refreshButtonTapped
    case visitTapped(String)
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
    
    UITableView.appearance().separatorInset = .zero
    UITableView.appearance().backgroundColor = .clear
    UITableView.appearance().separatorColor = UIColor(
      red: 199.0 / 255.0,
      green: 198.0 / 255.0,
      blue: 205.0 / 255.0,
      alpha: 1.0
    )
    UITabBar.appearance().isTranslucent = false
    UITabBar.appearance().barTintColor = UIColor(named: "TabBarBackgroundColor")
    UITabBar.appearance(for: .init(userInterfaceStyle: .dark)).backgroundImage = UIColor.gunPowder.image()
    UITabBar.appearance(for: .init(userInterfaceStyle: .light)).backgroundImage = UIColor.white.image()
    UITabBar.appearance(for: .init(userInterfaceStyle: .dark)).shadowImage = UIColor.gunPowder.image()
    UITabBar.appearance(for: .init(userInterfaceStyle: .light)).shadowImage = UIColor.white.image()
  }
  
  public var body: some View {
    Navigation(
      title: "Visits",
      leading: {
        Button("Clock Out") {
          send(.clockOutButtonTapped)
        }
        .font(.normalHighBold)
        .foregroundColor(colorScheme == .dark ? .white : .black)
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
              text: state.refreshing ? "Updating visits." : state.noVisits ? "No visits for today, tap refresh to update." : "You've made \(state.completed.count + state.canceled.count) out of \(state.totalVisits) visits so far.",
              state: state.noVisits ? .custom(color: Color.gray) : .visited
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
                visitSection(
                  for: .pending,
                  items: state.pending
                ) { send(.visitTapped($0.id)) }
              }
              if !state.visited.isEmpty {
                visitSection(
                  for: .visited,
                  items: state.visited
                ) { send(.visitTapped($0.id)) }
              }
              if !state.completed.isEmpty {
                visitSection(
                  for: .completed,
                  items: state.completed
                ) { send(.visitTapped($0.id)) }
              }
              if !state.canceled.isEmpty {
                visitSection(
                  for: .canceled,
                  items: state.canceled
                ) { send(.visitTapped($0.id)) }
              }
            }
            .modifier(AppBackground())
            .listStyle(GroupedListStyle())
            .environment(\.horizontalSizeClass, .regular)
          }
          .padding([.bottom], state.showManualVisits ? 78 : 0)
          if state.showManualVisits {
            VStack {
              Spacer()
              RoundedStack {
                PrimaryButton(
                  variant: .normal(title: "Add Visit")
                ) {
                  send(.addVisitButtonTapped)
                }
                .padding([.trailing, .leading], 58)
              }
              .padding(.bottom, -10)
            }
          }
        }
      }
    )
    .modifier(AppBackground())
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
      state: .init(
        pending: [.init(id: "1", title: "1301 Market St")],
        visited: [.init(id: "5", title: "2402 Davey St")],
        completed: [.init(id: "2", title: "275 Hayes St"), .init(id: "3", title: "Visit 12:30 AM — 01:15 PM")],
        canceled: [.init(id: "4", title: "4 Embracadero Ctr")],
        isNetworkAvailable: false,
        refreshing: false,
        showManualVisits: true,
        deviceID: "blank",
        publishableKey: "blank"
      ),
      send: { _ in }
    )
    .previewScheme(.dark)
  }
}

extension UIColor {
  func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
    return UIGraphicsImageRenderer(size: size).image { rendererContext in
      self.setFill()
      rendererContext.fill(CGRect(origin: .zero, size: size))
    }
  }
}
