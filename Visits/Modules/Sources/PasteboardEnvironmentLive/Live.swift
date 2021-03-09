import LogEnvironment
import PasteboardEnvironment
import UIKit


public extension PasteboardEnvironment {
  static let live = Self(
    copyToPasteboard: { s in
      .fireAndForget {
        logEffect("copyToPasteboard: \(s)")
        UIPasteboard.general.string = s.rawValue
      }
    }
  )
}
