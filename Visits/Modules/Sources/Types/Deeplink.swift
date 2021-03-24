import Foundation

public enum ProcessingDeepLink: Equatable {
  case waitingForDeepLink
  case waitingForTimerWith(PublishableKey, DriverID?)
  case waitingForSDKWith(PublishableKey, DriverID)
}
