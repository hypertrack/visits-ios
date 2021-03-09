import ComposableArchitecture
import HapticFeedbackEnvironment
import LogEnvironment
import UIKit

public extension HapticFeedbackEnvironment {
  static let live = Self(
    notifySuccess: {
      .fireAndForget {
        logEffect("notifySuccess")
        UINotificationFeedbackGenerator()
          .notificationOccurred(.success)
      }
    }
  )
}

