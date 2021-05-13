import ComposableArchitecture
import NonEmpty
import Types


public extension AppBundleDependency {
  static func mock(
    appVersion: NonEmptyString
  ) -> Self {
    .init(
      appVersion: { Effect(value: .init(rawValue: appVersion)) }
    )
  }
  
  static let noop = Self(
    appVersion: { .none }
  )
}
