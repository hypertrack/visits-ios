import SwiftUI

extension View {
  @inlinable public func previewScheme(_ colorScheme: ColorScheme) -> some View {
    self.modifier(PreviewScheme(colorScheme))
  }
}

public struct PreviewScheme: ViewModifier {
  private let colorScheme: ColorScheme
  
  public init(_ colorScheme: ColorScheme) {
    self.colorScheme = colorScheme
  }
  
  public func body(content: Content) -> some View {
    ZStack {
      switch self.colorScheme {
      case .light: Color.white
      case .dark: Color.haiti
      @unknown default: Color.haiti
      }
      content
        .environment(\.colorScheme, colorScheme)
        .preferredColorScheme(colorScheme)
    }
  }
}
