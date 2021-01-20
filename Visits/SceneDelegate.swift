import AppAdapter
import AppScreen
import Architecture
import Prelude
import SwiftUI


class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?
  
  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    if let windowScene = scene as? UIWindowScene {
      deepLink(from: connectionOptions.userActivities)
        <¡> send(viewStore) <<< LifeCycleAction.deepLinkOpened
      
      let window = UIWindow(windowScene: windowScene)
      window.rootViewController = UIHostingController(
        rootView: AppScreen(store: .appScreenStore(from: store))
      )
      window.tintColor = UIColor(named: "AccentColor")
      self.window = window
      window.makeKeyAndVisible()
    }
  }
  
  func scene(_: UIScene, continue userActivity: NSUserActivity) {
    deepLink(from: [userActivity])
      <¡> send(viewStore) <<< LifeCycleAction.deepLinkOpened
  }
  
  func sceneWillEnterForeground(_ scene: UIScene) {
    viewStore.send(.willEnterForeground)
  }
}
