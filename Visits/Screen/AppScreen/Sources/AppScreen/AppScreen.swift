import BlockerScreen
import ComposableArchitecture
import DeepLinkScreen
import DriverIDScreen
import LoadingScreen
import SignInScreen
import SwiftUI
import VisitScreen
import VisitsScreen
import WebKit

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
    case visits(VisitOrVisits)
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
        VisitsBlock(
          state: s,
          sendVisit: { viewStore.send(.visit($0)) },
          sendVisits: { viewStore.send(.visits($0)) }
        )
      }
    }
  }
}

struct VisitsBlock: View {
  let state: VisitOrVisits
  let sendVisit: (VisitScreen.Action) -> Void
  let sendVisits: (VisitsScreen.Action) -> Void
  
  var body: some View {
    TabView {
      switch state {
      case let .visit(v):
        VisitScreen(state: v) {
          sendVisit($0)
        }
        .tabItem {
          Image(systemName: "list.dash")
          Text("Visits")
        }
      case let .visits(vs):
        VisitsScreen(state: vs) {
          sendVisits($0)
        }
        .tabItem {
          Image(systemName: "list.dash")
          Text("Visits")
        }
      }
      WebView(
        deviceID: state.credentials.deviceID,
        publishableKey: state.credentials.publishableKey
      )
      .edgesIgnoringSafeArea(.top)
      .tabItem {
        Image(systemName: "map")
        Text("Map")
      }
    }
  }
}


struct WebView: UIViewRepresentable {
  let deviceID: String
  let publishableKey: String
  
  func makeUIView(context: Context) -> WKWebView {
    let webView = WKWebView(frame: .zero)
    webView.scrollView.bounces = false
    webView.load(
      URLRequest(
        url: URL(
          string: "https://embed.hypertrack.com/devices/\(deviceID)?publishable_key=\(publishableKey)&back=false"
        )!
      )
    )
    return webView
  }
  
  func updateUIView(_ webView: WKWebView, context: Context) {}
}

extension WKWebView {
  override open var safeAreaInsets: UIEdgeInsets {
    return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
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
