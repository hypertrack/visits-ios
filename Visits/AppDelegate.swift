import AppAdapter
import UIKit


class AppDelegate: UIResponder, UIApplicationDelegate {

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    setupUIAppearance()

    viewStore.send(.finishedLaunching)
    return true
  }

  // MARK: - Remote Notifications

  func application(
    _: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable: Any],
    fetchCompletionHandler completionHandler:
      @escaping (UIBackgroundFetchResult) -> Void
  ) {
    if userInfo["hypertrack"] == nil {
      viewStore.send(.receivedPushNotification)
    }
  }
}
