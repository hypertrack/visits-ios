import SwiftUI

public struct LoadingScreen: View {
  
  public init() {}
  
  public var body: some View {
    ZStack {
      Color("LaunchScreenBackgroundColor")
        .edgesIgnoringSafeArea(.all)
      Image("logo")
    }
  }
}

struct LoadingScreen_Previews: PreviewProvider {
  static var previews: some View {
    LoadingScreen()
  }
}
