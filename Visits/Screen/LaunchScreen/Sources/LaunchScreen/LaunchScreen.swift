import SwiftUI

public struct LaunchScreen: View {
  
  public init() {}
  
  public var body: some View {
    ZStack {
      Color("LaunchScreenBackgroundColor")
        .edgesIgnoringSafeArea(.all)
      Image("logo")
    }
  }
}

struct LaunchScreen_Previews: PreviewProvider {
  static var previews: some View {
    LaunchScreen()
  }
}
