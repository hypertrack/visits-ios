import SwiftUI
import UIKit
import ViewsComponents
import ComposableArchitecture
import Combine
import Prelude

func applyViewStyle() {
  UITableView.appearance().separatorInset = .zero
  UITableView.appearance().backgroundColor = .clear
  UITableView.appearance().separatorColor = UIColor.TableView.separatorColor
}

enum Status: String {
  case pending = "⏳ Pending"
  case completed = "🏁 Completed"
  case visited = "Visited"
}

public struct DeliveriesView: View {
  public struct State: Equatable {
    let completed: [DeliveryModel]
    let isNetworkAvailable: Bool
    let isTracking: Bool
    let pending: [DeliveryModel]
    let refreshButtonDisabled: Bool
    let refreshing: Bool
    
    public init(
      completed: [DeliveryModel],
      isNetworkAvailable: Bool,
      isTracking: Bool,
      pending: [DeliveryModel],
      refreshButtonDisabled: Bool,
      refreshing: Bool
    ) {
      self.completed = completed
      self.isNetworkAvailable = isNetworkAvailable
      self.isTracking = isTracking
      self.pending = pending
      self.refreshButtonDisabled = refreshButtonDisabled
      self.refreshing = refreshing
    }
  }
  enum Action {
    case refreshButtonTapped
    case deliveryCellTapped(DeliveryModel)
  }
  
  let store: Store<DeliveriesView.State, DeliveriesAction>
  @ObservedObject private var viewStore: ViewStore<DeliveriesView.State, DeliveriesView.Action>

  public init(store: Store<DeliveriesView.State, DeliveriesAction>) {
    self.store = store
    self.viewStore = ViewStore(
      self.store.scope(
        state: { $0 },
        action: DeliveriesAction.init(action:)
      )
    )
    applyViewStyle()
  }
  
  public var body: some View {
    Navigation(
      title: "Deliveries",
      leading: {
        EmptyView()
      },
      trailing: {
        NavigationRefreshButton(
        isDisabled: !self.viewStore.isNetworkAvailable,
        isRefreshing: self.viewStore.refreshing) {
          self.viewStore.send(.refreshButtonTapped)
        }
      },
      content: {
        VStack(spacing: 0) {
          NotificationView(
            text: self.viewStore.refreshing ? "Updating deliveries list." : self.viewStore.completed.isEmpty && self.viewStore.pending.isEmpty ? "No deliveries for today, tap refresh to update." : "You visited \(self.viewStore.completed.count) out of \(self.viewStore.completed.count + self.viewStore.pending.count) deliveries so far.",
            state: self.viewStore.completed.isEmpty && self.viewStore.pending.isEmpty ? .custom(color: Color.gray) : .primary
          )
            .padding(.top, 44)
          if !self.viewStore.isNetworkAvailable {
            NotificationView(
              text: "Network unavailable.",
              state: .custom(color: Color.gray)
            )
          }
          List {
            if !self.viewStore.pending.isEmpty {
              self.deliverySection(for: .pending, items: self.viewStore.pending, didSelect: { self.viewStore.send(.deliveryCellTapped($0)) })
            }
            if !self.viewStore.completed.isEmpty {
              self.deliverySection(for: .completed, items: self.viewStore.completed, didSelect: { self.viewStore.send(.deliveryCellTapped($0)) })
            }
          }
          .environment(\.horizontalSizeClass, .regular)
          .listStyle(GroupedListStyle())
        }
        .modifier(AppBackground())
        .edgesIgnoringSafeArea(.bottom)
    })
  }
}

private extension DeliveriesView {
  private func deliverySection(for status: Status, items: [DeliveryModel], didSelect cell: @escaping (DeliveryModel) -> Void) -> some View {
    SectionView(headerTitle: "\(status.rawValue)") {
      ForEach(items) { item in
        DeliveryCell(title: "\(item.shortAddress)") {
          cell(item)
        }
      }
    }
  }
}

extension DeliveriesAction {
  init(action: DeliveriesView.Action) {
    switch action {
    case let .deliveryCellTapped(delivery):
      self = .selectDelivery(delivery)
    case .refreshButtonTapped:
      self = .updateDeliveries
    }
  }
}

struct DeliveriesView_Previews: PreviewProvider {
  static var previews: some View {
    DeliveriesView(store:
      Store<DeliveriesView.State, DeliveriesAction>(
        initialState: DeliveriesView.State(
          completed: [
            DeliveryModel(
              id: NonEmptyString(stringLiteral: "aa34sdf"),
              createdAt: Date(),
              lat: 32.358,
              lng: 47.398,
              shortAddress: "Lenina square 25",
              fullAddress: "",
              metadata: []
            )
          ],
          isNetworkAvailable: false,
          isTracking: true,
          pending: [
            DeliveryModel(
              id: NonEmptyString(stringLiteral: "asdf"),
              createdAt: Date(),
              lat: 32.358,
              lng: 47.398,
              shortAddress: "Prospekt of Freedom 37",
              fullAddress: "",
              metadata: []
            ),
            DeliveryModel(
              id: NonEmptyString(stringLiteral: "as2335df"),
              createdAt: Date(),
              lat: 32.358,
              lng: 47.398,
              shortAddress: "Vokzalna street 14",
              fullAddress: "Vokzalna street 14",
              metadata: []
            )
          ],
          refreshButtonDisabled: false,
          refreshing: false
        ),
        reducer: .empty,
        environment: ()
      )
    ).environment(\.colorScheme, .light)
  }
}
