public enum AppState: Equatable {
  case waitingToFinishLaunching
  case restoringState(StorageState?)
  case launchingSDK(StorageState)
  case starting(StorageState, SDKStatusUpdate)
  case operational(OperationalState)
}
