import AppLogic
import Types

import APIEnvironmentLive
import BranchEnvironmentLive
import HapticFeedbackEnvironmentLive
import HyperTrackEnvironmentLive
import MapEnvironmentLive
import NetworkEnvironmentLive
import PasteboardEnvironmentLive
import PushEnvironmentLive
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
    push: .live,
    stateRestoration: .live
  )
  
  static func simulator(deviceID: DeviceID, publishableKey: PublishableKey) -> Self {
    Self(
      api: .live,
      deepLink: .live,
      hapticFeedback: .live,
      hyperTrack: .simulator(deviceID: deviceID, publishableKey: publishableKey),
      maps: .live,
      network: .live,
      pasteboard: .live,
      push: .live,
      stateRestoration: .live
    )
  }
}

