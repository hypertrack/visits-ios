import SwiftUI

public struct CustomText: View {
  @Environment(\.colorScheme) var colorScheme
  private let text: String
  
  public init(text: String) {
    self.text = text
  }
  
  public var body: some View {
    Text(text)
      .font(.smallMedium)
  }
}

struct GrayTextViewModifier: ViewModifier {
  func body(content: Content) -> some View {
    content
      .foregroundColor(.greySuit)
  }
}

private struct DefaultTextViewModifier: ViewModifier {
  @Environment(\.colorScheme) var colorScheme
  func body(content: Content) -> some View {
    content
      .foregroundColor(colorScheme == .dark ? .almostWhite : .gunPowder)
  }
}

public extension CustomText {
  func grayTextColor() -> some View {
    modifier(GrayTextViewModifier())
  }
  
  func defaultTextColor() -> some View {
    modifier(DefaultTextViewModifier(colorScheme: _colorScheme))
  }
}

struct TextView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      CustomText(text: "Link dark")
      .frame(width: 300, height: 48)
        .environment(\.colorScheme, .dark)
      CustomText(text: "Link light")
      .frame(width: 300, height: 48)
        .environment(\.colorScheme, .light)
    }
  }
}
