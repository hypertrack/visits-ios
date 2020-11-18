import BlockerScreen
import ComposableArchitecture
import DeepLinkScreen
import DriverIDScreen
import LoadingScreen
import SignInScreen
import SwiftUI
import VisitScreen
import VisitsScreen

public struct AppScreen: View {
  public enum State {
    case launch
    case deepLink(DeepLinkScreen.State)
    case signIn(SignInScreen.State)
    case driverID(DriverIDScreen.State)
    case blocker(Blocker.State)
    case visits(VisitsScreen.State)
    case visit(VisitScreen.State)
  }
  
  public enum Action {
    case signIn(SignInScreen.Action)
    case driverID(DriverIDScreen.Action)
    case blocker(Blocker.Action)
    case visits(VisitsScreen.Action)
    case visit(VisitScreen.Action)
  }
  
  let store: Store<State, Action>
  
  public init(store: Store<State, Action>) { self.store = store }
  
  public var body: some View {
    WithViewStore(store) { viewStore in
      switch viewStore.state {
      case .launch:
        LoadingScreen()
      case .deepLink:
        IfLetStore(
          store.actionless.scope(
            state: (/State.deepLink).extract(from:)
          ),
          then: DeepLinkScreen.init(store:)
        )
      case .signIn:
        IfLetStore(
          store.scope(
            state: (/State.signIn).extract(from:),
            action: Action.signIn
          ),
          then: SignInScreen.init(store:)
        )
      case .driverID:
        IfLetStore(
          store.scope(
            state: (/State.driverID).extract(from:),
            action: Action.driverID
          ),
          then: DriverIDScreen.init(store:)
        )
      case .blocker:
        IfLetStore(
          store.scope(
            state: (/State.blocker).extract(from:),
            action: Action.blocker
          ),
          then: Blocker.init(store:)
        )
      case .visits:
        IfLetStore(
          store.scope(
            state: (/State.visits).extract(from:),
            action: Action.visits
          ),
          then: VisitsScreen.init(store:)
        )
      case .visit:
        IfLetStore(
          store.scope(
            state: (/State.visit).extract(from:),
            action: Action.visit
          ),
          then: VisitScreen.init(store:)
        )
      }
    }
  }
}

extension AppScreen.State: Equatable {}

struct SwiftUIView_Previews: PreviewProvider {
  static var previews: some View {
    AppScreen(
      store: .init(
        initialState: .launch,
        reducer: .empty,
        environment: ()
      )
    )
  }
}
