import APIEnvironment
import BranchEnvironment
import ErrorReportingEnvironment
import HapticFeedbackEnvironment
import HyperTrackEnvironment
import MapEnvironment
import NetworkEnvironment
import PasteboardEnvironment
import PushEnvironment
import StateRestorationEnvironment


public struct AppEnvironment {
  public var api: APIEnvironment
  public var deepLink: BranchEnvironment
  public var errorReporting: ErrorReportingEnvironment
  public var hapticFeedback: HapticFeedbackEnvironment
  public var hyperTrack: HyperTrackEnvironment
  public var maps: MapEnvironment
  public var network: NetworkEnvironment
  public var pasteboard: PasteboardEnvironment
  public var push: PushEnvironment
  public var stateRestoration: StateRestorationEnvironment
  
  public init(api: APIEnvironment, deepLink: BranchEnvironment, errorReporting: ErrorReportingEnvironment, hapticFeedback: HapticFeedbackEnvironment, hyperTrack: HyperTrackEnvironment, maps: MapEnvironment, network: NetworkEnvironment, pasteboard: PasteboardEnvironment, push: PushEnvironment, stateRestoration: StateRestorationEnvironment) {
    self.api = api; self.deepLink = deepLink; self.errorReporting = errorReporting; self.hapticFeedback = hapticFeedback; self.hyperTrack = hyperTrack; self.maps = maps; self.network = network; self.pasteboard = pasteboard; self.push = push; self.stateRestoration = stateRestoration;
  }
}
