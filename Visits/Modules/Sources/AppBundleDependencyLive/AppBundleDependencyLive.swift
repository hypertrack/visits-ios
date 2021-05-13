import AppBundleDependency
import Foundation
import LogEnvironment


public extension AppBundleDependency {
  static let live = Self(
    appVersion: {
      .future { callback in
        callback(.success(.init(stringLiteral:"\(Bundle.main.releaseVersionNumber!) (\(Bundle.main.buildVersionNumber!))")))
      }
    }
  )
}
  
extension Bundle {
  var releaseVersionNumber: String? {
    return infoDictionary?["CFBundleShortVersionString"] as? String
  }
  var buildVersionNumber: String? {
    return infoDictionary?["CFBundleVersion"] as? String
  }
}
