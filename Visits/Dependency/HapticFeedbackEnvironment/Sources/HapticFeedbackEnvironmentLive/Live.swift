import ComposableArchitecture
import HapticFeedbackEnvironment
import UIKit

public extension HapticFeedbackEnvironment {
  static let live = Self(
    notifySuccess: {
      .fireAndForget {
        print("🚀 notifySuccess")
        UINotificationFeedbackGenerator()
          .notificationOccurred(.success)
      }
    }
  )
}

