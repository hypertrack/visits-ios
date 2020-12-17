import App

import APIEnvironmentLive
import DeepLinkEnvironmentLive
import HapticFeedbackEnvironmentLive
import HyperTrackEnvironmentLive
import MapEnvironmentLive
import NetworkEnvironmentLive
import PasteboardEnvironmentLive
import StateRestorationEnvironmentLive


public extension AppEnvironment {
  static let live = Self(
    api: .live,
    deepLink: .live,
    hapticFeedback: .live,
    hyperTrack: .live,
    maps: .live,
    network: .live,
    pasteboard: .live,
    stateRestoration: .live
  )
}
