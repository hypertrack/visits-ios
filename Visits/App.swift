import AppScreen
import Combine
import SwiftUI


@main
struct Visits: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  @Environment(\.scenePhase) private var scenePhase
  
  var body: some Scene {
    WindowGroup {
      AppScreen(store: .appScreenStore(from: store))
        .onOpenURL { url in
          viewStore.send(.deepLinkOpened(url))
        }
        .onReceive(Just(scenePhase)) { scenePhase in
          if scenePhase == .active {
            viewStore.send(.willEnterForeground)
          }
        }
    }
  }
}
 
