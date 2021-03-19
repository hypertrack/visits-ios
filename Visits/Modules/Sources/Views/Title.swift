import SwiftUI

public struct Title: View {
  @Environment(\.colorScheme) var colorScheme
  private let title: String
  private let withCheck: Bool
  
  public init(title: String, withCheck: Bool = false) {
    self.title = title
    self.withCheck = withCheck
  }
  
  public var body: some View {
    GeometryReader { geometry in
      VStack(alignment: .center, spacing: 0.0) {
        HStack {
          if withCheck {
            ZStack {
              Image(systemName: "checkmark.circle.fill")
                .font(.hugeSemibold)
                .foregroundColor(.blue)
                .background(Circle().foregroundColor(.white).padding(2))
            }
            .padding(.top, 44)
          }
          Text(title)
            .font(.hugeSemibold)
            .foregroundColor(colorScheme == .dark ? .white : .gunPowder)
            .padding(.top, 44)
        }
      }
      .frame(width: geometry.size.width, height: 80)
      .modifier(AppBackground())
    }
    .frame(height: 80)
  }
}

struct TitleView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      Title(title: "Sign up a new account", withCheck: true)
        .environment(\.colorScheme, .dark)
      Title(title: "Sign up a new account")
        .environment(\.colorScheme, .light)
    }
    .previewLayout(.sizeThatFits)
  }
}

