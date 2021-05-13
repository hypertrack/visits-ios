import ComposableArchitecture
import Types


public struct AppBundleDependency {
  public var appVersion: () -> Effect<AppVersion, Never>
  
  public init(
    appVersion: @escaping () -> Effect<AppVersion, Never>
  ) {
    self.appVersion = appVersion
  }
}
