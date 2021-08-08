import SwiftUI


struct TimelinePieceView<Content: View>: View {
  private let content: () -> Content
  
  init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content
  }
  
  var body: some View {
    ZStack(alignment: .leading) {
      Color(.secondarySystemBackground)
      content()
        .padding()
    }
    .clipShape(RoundedRectangle(cornerRadius: 8))
  }
}
