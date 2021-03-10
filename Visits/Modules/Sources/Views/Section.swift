import SwiftUI

public struct CustomSection<Content: View>: View {
  @Environment(\.colorScheme) var colorScheme
  private let header: String
  private let content: () -> Content
  
  public init(header: String, @ViewBuilder content: @escaping () -> Content) {
    self.header = header
    self.content = content
  }
  
   public var body: some View {
    Section {
      HStack {
        Spacer()
        Text(header)
          .font(.normalLowMedium)
          .foregroundColor(colorScheme == .dark ? .white : .gunPowder)
        Spacer()
      }
      content()
    }
    .listRowBackground(colorScheme == .dark ? Color.gunPowder : .lilyWhite)
  }
}

struct SectionView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      VStack {
        CustomSection(header: "Pending deliveries") {
          ContentCell(title: "address", subTitle: "501 Twin Peaks Blvd, San Francisco, CA 94114 501 Twin Peaks Blvd, San Francisco, CA 94114 ")
        }
      }
      .environment(\.colorScheme, .light)
      .preferredColorScheme(.light)
      VStack {
        CustomSection(header: "Pending deliveries") {
          ContentCell(title: "address", subTitle: "501 Twin Peaks Blvd, San Francisco, CA 94114 501 Twin Peaks Blvd, San Francisco, CA 94114 ")
        }
      }
      .environment(\.colorScheme, .dark)
      .preferredColorScheme(.dark)
    }
    .previewLayout(.sizeThatFits)
  }
}
