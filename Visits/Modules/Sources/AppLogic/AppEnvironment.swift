import APIEnvironment
import AppBundleDependency
import BranchEnvironment
import ErrorReportingEnvironment
import HapticFeedbackEnvironment
import HyperTrackEnvironment
import MapEnvironment
import PasteboardEnvironment
import PushEnvironment
import StateRestorationEnvironment


public struct AppEnvironment {
  public var api: APIEnvironment
  public var bundle: AppBundleDependency
  public var deepLink: BranchEnvironment
  public var errorReporting: ErrorReportingEnvironment
  public var hapticFeedback: HapticFeedbackEnvironment
  public var hyperTrack: HyperTrackEnvironment
  public var maps: MapEnvironment
  public var pasteboard: PasteboardEnvironment
  public var push: PushEnvironment
  public var stateRestoration: StateRestorationEnvironment
  
  public init(api: APIEnvironment, bundle: AppBundleDependency, deepLink: BranchEnvironment, errorReporting: ErrorReportingEnvironment, hapticFeedback: HapticFeedbackEnvironment, hyperTrack: HyperTrackEnvironment, maps: MapEnvironment, pasteboard: PasteboardEnvironment, push: PushEnvironment, stateRestoration: StateRestorationEnvironment) {
    self.api = api; self.bundle = bundle; self.deepLink = deepLink; self.errorReporting = errorReporting; self.hapticFeedback = hapticFeedback; self.hyperTrack = hyperTrack; self.maps = maps; self.pasteboard = pasteboard; self.push = push; self.stateRestoration = stateRestoration;
  }
}
