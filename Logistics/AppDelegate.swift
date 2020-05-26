import UIKit

import HyperTrack
import Branch

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    HyperTrack.registerForRemoteNotifications()
    Branch.getInstance().initSession(
      launchOptions: launchOptions,
      andRegisterDeepLinkHandler: { params, error in
        if let branchParams = params, error == nil {
          NotificationDidReceiveNewBranchParams(params: branchParams)
        }
      }
    )
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
    HyperTrack.didReceiveRemoteNotification(
      userInfo,
      fetchCompletionHandler: completionHandler
    )
  }

  // MARK: UISceneSession Lifecycle

  func application(
    _ application: UIApplication,
    configurationForConnecting connectingSceneSession: UISceneSession,
    options: UIScene.ConnectionOptions
  ) -> UISceneConfiguration {
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }
}

func NotificationDidReceiveNewBranchParams(params: [AnyHashable : Any]) {
  
  let branchPublishableKey = params["publishable_key"] as? String
  guard let publishableKey = branchPublishableKey, !publishableKey.isEmpty else { return }
  
  DispatchQueue.main.async {
    NotificationCenter.default.post(
      name: NSNotification.Name(
        rawValue: "notification_did_receive_new_params"
      ),
      object: nil,
      userInfo: ["publishable_key": publishableKey]
    )
  }
}
