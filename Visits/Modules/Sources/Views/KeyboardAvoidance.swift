import SwiftUI

extension View {
  @inlinable public func ignoreKeyboard() -> some View {
    modifier(IgnoreKeyboard())
  }
}

public struct IgnoreKeyboard: ViewModifier {
  
  public init() { }
  
  @ViewBuilder
  public func body(content: Content) -> some View {
    content
      .ignoresSafeArea(.keyboard)
  }
}
