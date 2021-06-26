public struct AppLaunching: Equatable {
  public enum StateAndSDK: Equatable {
    case restoringState(RestoredState?)
    case launchingSDK(RestoredState)
    case starting(RestoredState, SDKStatusUpdate)
  }
  
  public var stateAndSDK: StateAndSDK?
  public var visibility: AppVisibility?
  
  public init(stateAndSDK: StateAndSDK? = nil, visibility: AppVisibility? = nil) {
    self.stateAndSDK = stateAndSDK; self.visibility = visibility
  }
}
