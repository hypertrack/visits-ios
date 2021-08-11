import SwiftUI


public struct PrimaryRow: View {
  public let text: String
  
  public init(_ text: String) { self.text = text }
  
  public var body: some View {
    HStack {
      Text(text)
        .font(.headline)
        .foregroundColor(Color(.label))
        .fixedSize(horizontal: false, vertical: true)
      Spacer()
    }
  }
}

public struct SecondaryRow: View {
  public let text: String
  
  public init(_ text: String) { self.text = text }
  
  public var body: some View {
    HStack {
      Text(text)
        .font(.footnote)
        .foregroundColor(Color(.secondaryLabel))
        .fontWeight(.bold)
        .fixedSize(horizontal: false, vertical: true)
      Spacer()
    }
  }
}
