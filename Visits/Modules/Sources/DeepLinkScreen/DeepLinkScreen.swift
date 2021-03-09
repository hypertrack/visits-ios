import ComposableArchitecture
import SwiftUI
import Views

public struct DeepLinkScreen: View {
  public struct State: Equatable {
    public var time: TimeInterval
    public var work: Work
    
    public init(time: TimeInterval, work: DeepLinkScreen.Work) {
      self.time = time
      self.work = work
    }
  }
  
  public enum Work { case connecting, sdk }
  
  let state: State
  
  public init(state: State) { self.state = state }
  
  @SwiftUI.State var progress = 0.0
  let timer = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common).autoconnect()
  
  public var body: some View {
    VStack {
      Spacer()
      Title(title: "Opening the deep link")
      if #available(iOS 14.0, *) {
        ProgressView(value: progress, total: 5.0, label: {}) {
          switch state.work {
          case .connecting:
            Text("Connecting to server...")
          case .sdk:
            Text("Launching services...")
          }
        }
        .padding([.leading, .trailing],16)
        .padding(.bottom, 100)
      }
      Spacer()
    }
    .appBackground()
    .edgesIgnoringSafeArea(.all)
    .onReceive(timer) { _ in
      let next = progress + 1.0 / 60.0
      if next < state.time {
        progress = next
      }
    }
  }
}

struct DeepLinkScreen_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      DeepLinkScreen(state: .init(time: 5, work: .connecting))
        .previewScheme(.light)
      DeepLinkScreen(state: .init(time: 5, work: .sdk))
        .previewScheme(.dark)
    }
    .accentColor(.malachite)
  }
}
