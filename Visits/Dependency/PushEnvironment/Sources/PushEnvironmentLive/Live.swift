import Log
import PushEnvironment
import UserNotifications


public extension PushEnvironment {
  static let live = Self(
    requestAuthorization: {
      .fireAndForget {
        logEffect("requestAuthorization:")
        UNUserNotificationCenter.current()
          .requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            logEffect("requestAuthorization: granted: \(granted), error: \(error?.localizedDescription ?? "nil")")
          }
      }
    }
  )
}
