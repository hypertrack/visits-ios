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
  
  let store: Store<State, Never>
  
  public init(store: Store<State, Never>) { self.store = store }
  
  @SwiftUI.State var progress = 0.0
  let timer = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common).autoconnect()
  
  public var body: some View {
    WithViewStore(store) { viewStore in
      VStack {
        Spacer()
        Title(title: "Opening the deep link")
        if #available(iOS 14.0, *) {
          ProgressView(value: progress, total: 5.0, label: {}) {
            switch viewStore.work {
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
        if next < viewStore.time {
          progress = next
        }
      }
    }
  }
}

struct DeepLinkScreen_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      DeepLinkScreen(
        store: .init(
          initialState: .init(time: 5, work: .connecting),
          reducer: .empty,
          environment: ()
        )
      )
        .previewScheme(.light)
      DeepLinkScreen(
        store: .init(
          initialState: .init(time: 5, work: .sdk),
          reducer: .empty,
          environment: ()
        )
      )
        .previewScheme(.dark)
    }
      .accentColor(.malachite)
  }
}
