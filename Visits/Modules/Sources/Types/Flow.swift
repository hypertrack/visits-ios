public enum AppFlow: Equatable {
  case firstRun
  case signIn(SignInState)
  case driverID(DriverIDState)
  case main(MainState)
  
  public static let firstScreen = Self.signIn(.entering(.init()))
}
