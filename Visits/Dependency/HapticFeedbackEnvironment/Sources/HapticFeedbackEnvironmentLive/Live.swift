import ComposableArchitecture
import HapticFeedbackEnvironment
import Log
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

