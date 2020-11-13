import PasteboardEnvironment
import UIKit


public extension PasteboardEnvironment {
  static let live = Self(
    copyToPasteboard: { s in
      .fireAndForget {
        print("🚀 copyToPasteboard")
        UIPasteboard.general.string = s.rawValue
      }
    }
  )
}
