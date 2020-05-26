import SwiftUI

import ComposableArchitecture
import Deliveries
import DriverID
import Delivery
import Location
import Prelude
import SignIn
import ViewBlocker


public struct AppView: View {
  struct State: Equatable {
    let showSignIn: Bool
    let showDriverID: Bool
    let showPermissions: Bool
  }
  
  let store: Store<AppState, AppAction>
  @ObservedObject private var viewStore: ViewStore<AppView.State, AppAction>
  
  public init(store: Store<AppState, AppAction>) {
    self.store = store
    self.viewStore = ViewStore(self.store.scope(state: State.init(appState:)))
  }
  
  public init(screenshotState: AppState) {
    self.init(store: Store<AppState, AppAction>(
      initialState: screenshotState,
      reducer: Reducer.empty,
      environment: ()
      )
    )
  }
  
  public var body: some View {
    Group {
      if viewStore.showSignIn {
        SignInView(store: self.store.scope(
          state: \.signInState,
          action: { .signIn($0) }
          )
        )
      } else if viewStore.showDriverID {
        DriverIDView(store: self.store.scope(
          state: \.driverIDState,
          action: { .driverID($0) }
          )
        )
      } else {
        IfLetStore(
          self.store.scope(
            state: \.blocker,
            action: AppAction.init(block:)
          ),
          then: Blocker.init(store:),
          else: IfLetStore(
            self.store.scope(
              state: \.deliveryState,
              action: AppAction.deliveryCasePath.embed
            ),
            then: DeliveryView.init(store:),
            else: IfLetStore(
              self.store.scope(
                state: \.deliveriesView,
                action: AppAction.deliveriesCasePath.embed
              ),
              then: DeliveriesView.init(store:)
            )
          )
        )
      }
    }
    .onAppear{ self.viewStore.send(.appAppeared) }
  }
}

extension AppView.State {
  init(appState: AppState) {
    switch appState.userStatus {
    case .new:
      self.showSignIn = true
      
      self.showDriverID = false
      self.showPermissions = false
    case .authenticated:
      self.showDriverID = true
      
      self.showSignIn = false
      self.showPermissions = false
    case .registered:
      self.showPermissions = true
      
      self.showDriverID = false
      self.showSignIn = false
    }
  }
}
