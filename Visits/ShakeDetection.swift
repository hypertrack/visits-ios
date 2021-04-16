import UIKit


extension UIWindow {
  open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
    if motion == .motionShake {
      viewStore.send(.shakeDetected)
    }
  }
}
