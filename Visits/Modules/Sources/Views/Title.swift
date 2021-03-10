import SwiftUI

public struct Title: View {
  @Environment(\.colorScheme) var colorScheme
  private let title: String
  private let subtitle: String
  
  public init(title: String, subtitle: String = "") {
    self.title = title
    self.subtitle = subtitle
  }
  
  public var body: some View {
    GeometryReader { geometry in
      VStack(alignment: .center, spacing: 0.0) {
        Text(title)
          .font(.hugeSemibold)
          .foregroundColor(colorScheme == .dark ? .white : .gunPowder)
          .padding(.top, 44)
        Text(subtitle)
          .font(.smallMedium)
          .foregroundColor(colorScheme == .dark ? .ghost : .greySuit)
      }
      .frame(width: geometry.size.width, height: 94)
      .modifier(AppBackground())
    }
    .frame(height: 94)
  }
}

struct TitleView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      Title(title: "Sign up a new account", subtitle: "14 day free trial. No Credit card required")
        .environment(\.colorScheme, .dark)
      Title(title: "Sign up a new account", subtitle: "14 day free trial. No Credit card required")
        .environment(\.colorScheme, .light)
    }
    .previewLayout(.sizeThatFits)
  }
}

