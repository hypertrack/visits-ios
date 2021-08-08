import AppLogic
import Types

import APIEnvironmentLive
import AppBundleDependencyLive
import BranchEnvironmentLive
import ErrorReportingEnvironmentLive
import HapticFeedbackEnvironmentLive
import HyperTrackEnvironmentLive
import MapDependencyLive
import PasteboardEnvironmentLive
import PushEnvironmentLive
import StateRestorationEnvironmentLive


public extension AppEnvironment {
  static let live = Self(
    api: .live,
    bundle: .live,
    deepLink: .live,
    errorReporting: .live,
    hapticFeedback: .live,
    hyperTrack: .live,
    maps: .live,
    pasteboard: .live,
    push: .live,
    stateRestoration: .live
  )
  static func simulator(deviceID: DeviceID, publishableKey: PublishableKey, storageState: StorageState?) -> Self {
    Self(
      api: .live,
      bundle: .live,
      deepLink: .live,
      errorReporting: .printing,
      hapticFeedback: .live,
      hyperTrack: .simulator(deviceID: deviceID, publishableKey: publishableKey),
      maps: .live,
      pasteboard: .live,
      push: .live,
      stateRestoration: .mock(initialState: storageState)
    )
  }
}

