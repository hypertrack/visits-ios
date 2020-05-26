import UIKit

import ComposableArchitecture

import Notification


extension NotificationEnvironment {
  public static let live = NotificationEnvironment(
    subscribeToEnterForeground: {
      NotificationCenter
        .default
        .publisher(for: UIScene.willEnterForegroundNotification)
        .map { _ in () }
        .eraseToEffect()
    }
  )
}
