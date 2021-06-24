import SwiftUI
import Types


struct AutoZoomButton: View {
  public var sendEnableAutoZoom: () -> Void
  
  var body: some View {
    Button(action: sendEnableAutoZoom) {
      Image(systemName: "location")
        .foregroundColor(.accentColor)
        .frame(width: 40, height: 40)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
  }
}

struct SwiftUIView_Previews: PreviewProvider {
  static var previews: some View {
    AutoZoomButton(sendEnableAutoZoom: {})
      .preferredColorScheme(.light)
  }
}
