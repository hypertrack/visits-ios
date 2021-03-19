import SwiftUI

extension View {
  @inlinable public func ignoreKeyboard() -> some View {
    modifier(IgnoreKeyboard())
  }
}

public struct IgnoreKeyboard: ViewModifier {
  
  public init() { }
  
  public func body(content: Content) -> some View {
    if #available(iOS 14.0, *) {
      content
        .ignoresSafeArea(.keyboard)
    } else {
      content
    }
  }
}
