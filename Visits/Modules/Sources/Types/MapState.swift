public struct MapState: Equatable {
  public var autoZoom: AutoZoom
  
  public init(autoZoom: AutoZoom) {
    self.autoZoom = autoZoom
  }
}

public extension MapState {
  static let initialState = Self(autoZoom: .enabled)
}

public enum AutoZoom { case enabled, disabled }
