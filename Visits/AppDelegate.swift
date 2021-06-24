import HyperTrack
import AppAdapter
import UIKit


class AppDelegate: UIResponder, UIApplicationDelegate {

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    viewStore.send(.finishedLaunching)

    HyperTrack.registerForRemoteNotifications()
    return true
  }

  // MARK: - Remote Notifications

  func application(
    _: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    HyperTrack.didRegisterForRemoteNotificationsWithDeviceToken(deviceToken)
  }

  func application(
    _: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    HyperTrack.didFailToRegisterForRemoteNotificationsWithError(error)
  }

  func application(
    _: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable: Any],
    fetchCompletionHandler completionHandler:
      @escaping (UIBackgroundFetchResult) -> Void
  ) {
    if userInfo["hypertrack"] != nil {
      // This is HyperTrack SDK's notification
      HyperTrack.didReceiveRemoteNotification(
        userInfo,
        fetchCompletionHandler: completionHandler)
    } else {
      viewStore.send(.receivedPushNotification)
    }
  }
}
