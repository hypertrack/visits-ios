import Combine
import LogEnvironment
import PasteboardEnvironment
import Prelude
import Types
import UIKit


public extension PasteboardEnvironment {
  static let live = Self(
    copyToPasteboard: { s in
      .fireAndForget {
        logEffect("copyToPasteboard: \(s)")
        UIPasteboard.general.string = s.rawValue
      }
    },
    verificationCodeFromPasteboard: {
      .result {
        logEffect("verificationCodeFromPasteboard:")
        
        guard UIPasteboard.general.hasStrings else { return .success(nil) }
        
        if let item = UIPasteboard.general.string,
           let code = VerificationCode.init(string: item),
           lastCode == nil || lastCode != code {
          logEffect("verificationCodeFromPasteboard: \(code)")
          
          lastCode = code
          UIPasteboard.general.items = []
          return .success(code)
        } else {
          return .success(nil)
        }
      }
    }
  )
}

var cancellables: Set<AnyCancellable> = []
var lastCode: VerificationCode?
