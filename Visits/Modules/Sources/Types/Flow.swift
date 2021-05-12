public enum AppFlow: Equatable {
  case firstRun
  case signUp(SignUpState)
  case signIn(SignInState)
  case driverID(DriverIDState)
  case main(MainState)
  
  public static let firstScreen = Self.signUp(.form(.empty))
}
