import Log
import PushEnvironment
import UserNotifications


public extension PushEnvironment {
  static let live = Self(
    requestAuthorization: {
      .future { callback in
        logEffect("requestAuthorization:")
        UNUserNotificationCenter.current()
          .requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            logEffect("requestAuthorization: granted: \(granted), error: \(error?.localizedDescription ?? "nil")")
            callback(.success(()))
          }
      }
    }
  )
}
