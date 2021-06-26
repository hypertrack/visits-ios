public enum AppState: Equatable {
  case launching(AppLaunching)
  case operational(OperationalState)
}

public extension AppState {
  static let initialState = Self.launching(.init())
}
