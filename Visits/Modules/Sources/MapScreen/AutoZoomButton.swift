import SwiftUI
import Types


struct AutoZoomButton: View {
  public var autoZoom: AutoZoom
  public var sendToggleAutoZoom: () -> Void
  
  var body: some View {
    Button(action: sendToggleAutoZoom) {
      Image(systemName: autoZoom == .enabled ? "location.fill" : "location")
        .foregroundColor(.accentColor)
        .frame(width: 40, height: 40)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
  }
}

struct SwiftUIView_Previews: PreviewProvider {
  static var previews: some View {
    AutoZoomButton(
      autoZoom: .enabled,
      sendToggleAutoZoom: {}
    )
      .preferredColorScheme(.light)
  }
}
