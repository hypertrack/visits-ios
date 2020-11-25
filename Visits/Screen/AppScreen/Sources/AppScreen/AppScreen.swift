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
    case loading
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
      case .loading:
        LoadingScreen()
      case let .deepLink(s):
        DeepLinkScreen(state: s)
      case let .signIn(s):
        SignInScreen(state: s) {
          viewStore.send(.signIn($0))
        }
      case let .driverID(s):
        DriverIDScreen(state: s) {
          viewStore.send(.driverID($0))
        }
      case let .blocker(s):
        Blocker(state: s) {
          viewStore.send(.blocker($0))
        }
      case let .visits(s):
        VisitsScreen(state: s) {
          viewStore.send(.visits($0))
        }
      case let .visit(s):
        VisitScreen(state: s) {
          viewStore.send(.visit($0))
        }
      }
    }
  }
}

extension AppScreen.State: Equatable {}

struct SwiftUIView_Previews: PreviewProvider {
  static var previews: some View {
    AppScreen(
      store: .init(
        initialState: .loading,
        reducer: .empty,
        environment: ()
      )
    )
  }
}
