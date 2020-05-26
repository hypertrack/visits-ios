import ComposableArchitecture
import Prelude

import Deeplink



extension DeeplinkEnvironment {
  public static let live = DeeplinkEnvironment(
    checkPublishableKey: {
      Effect(value: UserDefaults.standard.string(forKey: "UeiDZRFEOd"))
    },
    subscribeToDeeplinkSuccess: {
      NotificationCenter
      .default
      .publisher(for: NSNotification.Name(
        rawValue: "notification_did_receive_new_params"
      ))
      .map { $0.userInfo?["publishable_key"] as? String }
      .eraseToEffect()
    }
  )
}
