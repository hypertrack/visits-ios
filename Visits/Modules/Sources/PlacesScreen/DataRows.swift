import SwiftUI


struct PrimaryRow: View {
  let text: String
  
  init(_ text: String) { self.text = text }
  
  var body: some View {
    HStack {
      Text(text)
        .font(.headline)
        .foregroundColor(Color(.label))
      Spacer()
    }
  }
}

struct SecondaryRow: View {
  let text: String
  
  init(_ text: String) { self.text = text }
  
  var body: some View {
    HStack {
      Text(text)
        .font(.footnote)
        .foregroundColor(Color(.secondaryLabel))
        .fontWeight(.bold)
      Spacer()
    }
  }
}
