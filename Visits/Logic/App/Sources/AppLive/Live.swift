import App

import APIEnvironment
import APIEnvironmentLive
import DeepLinkEnvironmentLive
import HapticFeedbackEnvironmentLive
import HyperTrackEnvironmentLive
import MapEnvironmentLive
import NetworkEnvironmentLive
import PasteboardEnvironmentLive
import StateRestorationEnvironmentLive

// For AWS SDK
import ComposableArchitecture
import Credentials
import NonEmpty
import Prelude
import PublishableKey


public extension AppEnvironment {
  static let live:(@escaping (Email, Password) -> Effect<Either<PublishableKey, NonEmptyString>, Never>) -> AppEnvironment = { signIn in
    AppEnvironment(
      api: APIEnvironment(getHistory: getHistory, getVisits: getVisits, reverseGeocode: reverseGeocode, signIn: signIn),
      deepLink: .live,
      hapticFeedback: .live,
      hyperTrack: .live,
      maps: .live,
      network: .live,
      pasteboard: .live,
      stateRestoration: .live
    )
  }
}
