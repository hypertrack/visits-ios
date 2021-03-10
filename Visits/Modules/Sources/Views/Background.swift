import SwiftUI

extension View {
  @inlinable public func appBackground() -> some View {
    modifier(AppBackground())
  }
}

public struct AppBackground: ViewModifier {
  @Environment(\.colorScheme) var colorScheme
  
  public init() { }
  
  public func body(content: Content) -> some View {
    content.background(colorScheme == .dark ? Color.haiti : .white)
  }
}
