public enum PushStatus {
  case dialogSplash(DialogSplashStatus)
}

public enum DialogSplashStatus { case shown, waitingForUserAction, notShown }


extension PushStatus: Equatable {}
extension DialogSplashStatus: Equatable {}
