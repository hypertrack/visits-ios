import SwiftUI

public struct RoundedStack<Content: View>: View {
  @Environment(\.colorScheme) var colorScheme
  private let content: () -> Content
  
  public init (@ViewBuilder content: @escaping () -> Content) {
    self.content = content
  }
  
  public var body: some View {
    GeometryReader { geometry in
      VStack(spacing: 0.0) {
        Spacer()
        VStack(spacing: 0.0) {
          content()
        }
        .background(colorScheme == .dark ? Color.gunPowder : .white)
        .cornerRadius(10.0)
        .shadow(radius: 10.0)
      }
      .frame(width: geometry.size.width)
    }
  }
}

struct RoundedStack_Previews: PreviewProvider {
  static var previews: some View {
    RoundedStack {
      HStack {
        PrimaryButton(
          variant: .normal(title: "Check Out"),
          showActivityIndicator: false,
          {}
        )
        .padding([.leading], 8)
        .padding([.trailing], 2.5)
        PrimaryButton(
          variant: .destructive(),
          showActivityIndicator: false,
          {}
        )
        .padding([.leading], 2.5)
        .padding([.trailing], 8)
      }
    }
    .edgesIgnoringSafeArea(.bottom)
  }
}
