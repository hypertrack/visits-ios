import SwiftUI

public struct VisitStatus: View {
  private let text: String
  private let state: State
  
  public enum State {
    case primary
    case visited
    case completed
    case custom(color: Color)
  }
  
  public init(text: String, state: State) {
    self.text = text
    self.state = state
  }
  
  public var body: some View {
    HStack(spacing: 0) {
      Spacer()
      if text.isEmpty {
        EmptyView()
      } else {
        Text(text)
          .font(.smallMedium)
          .foregroundColor(.white)
      }
      Spacer()
    }
    .padding(text.isEmpty ? 0 : 10)
    .background(getBackground())
  }
  
  private func getBackground() -> Color {
    switch state {
    case .primary:           return .dodgerBlue
    case .visited:         return .oldGold
    case .completed:       return .malachite
    case let .custom(color): return color
    }
  }
}

struct VisitStatus_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      VisitStatus(text: "Some text", state: .completed)
      VisitStatus(text: "Some text", state: .visited)
      VisitStatus(text: "Some text", state: .primary)
    }
    .previewLayout(.sizeThatFits)
  }
}
