import BlockerScreen
import ComposableArchitecture
import DeepLinkScreen
import DriverIDScreen
import History
import LoadingScreen
import MapScreen
import SignInScreen
import SwiftUI
import TabSelection
import VisitScreen
import VisitsScreen

public enum VisitOrVisits: Equatable {
  case visit(VisitScreen.State)
  case visits(VisitsScreen.State)
  
  var credentials: (deviceID: String, publishableKey: String) {
    switch self {
    case let .visit(s):
      return (s.deviceID, s.publishableKey)
    case let .visits(s):
      return (s.deviceID, s.publishableKey)
    }
  }
}

public struct AppScreen: View {
  public enum State {
    case loading
    case deepLink(DeepLinkScreen.State)
    case signIn(SignInScreen.State)
    case driverID(DriverIDScreen.State)
    case blocker(Blocker.State)
    case visits(VisitOrVisits, History?, TabSelection)
  }
  
  public enum Action {
    case signIn(SignInScreen.Action)
    case driverID(DriverIDScreen.Action)
    case blocker(Blocker.Action)
    case visits(VisitsScreen.Action)
    case visit(VisitScreen.Action)
    case tab(TabSelection)
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
      case let .visits(s, h, sel):
        VisitsBlock(
          state: (s, h, sel),
          sendVisit: { viewStore.send(.visit($0)) },
          sendVisits: { viewStore.send(.visits($0)) },
          sendTab: { viewStore.send(.tab($0)) }
        )
      }
    }
  }
}

struct VisitsBlock: View {
  let state: (visits: VisitOrVisits, history: History?, tabSelection: TabSelection)
  let sendVisit: (VisitScreen.Action) -> Void
  let sendVisits: (VisitsScreen.Action) -> Void
  let sendTab: (TabSelection) -> Void
  
  var body: some View {
    TabView(
      selection: Binding(
        get: { state.tabSelection },
        set: { sendTab($0) }
      )
    ) {
      switch state.visits {
      case let .visit(v):
        VisitScreen(state: v) {
          sendVisit($0)
        }
        .tabItem {
          Image(systemName: "list.dash")
          Text("Visits")
        }
        .tag(TabSelection.visits)
      case let .visits(vs):
        VisitsScreen(state: vs) {
          sendVisits($0)
        }
        .tabItem {
          Image(systemName: "list.dash")
          Text("Visits")
        }
        .tag(TabSelection.visits)
      }
      MapScreen(polyline: Binding.constant(state.history?.coordinates ?? []))
        .edgesIgnoringSafeArea(.top)
        .tabItem {
          Image(systemName: "map")
          Text("Map")
        }
        .tag(TabSelection.map)
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
