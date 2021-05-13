import NonEmpty
import Tagged

public enum AppState: Equatable {
  case waitingToFinishLaunching
  case restoringState(RestoredState?)
  case launchingSDK(RestoredState)
  case starting(RestoredState, SDKStatusUpdate)
  case operational(OperationalState)
}

public typealias AppVersion = Tagged<AppVersionTag, NonEmptyString>
public enum AppVersionTag {}
