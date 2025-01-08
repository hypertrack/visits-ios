import NonEmpty
import SwiftUI
import Types
import Views

public struct VisitsScreen: View {
  let state: VisitsView.ScreenState
    let send: (VisitsView.Action) -> Void

  public init(
    state: VisitsView.ScreenState,
    send: @escaping (VisitsView.Action) -> Void
  ) {
    self.state = state
    self.send = send
  }

  public var body: some View {
    NavigationView {
      VisitsView.init(
        state: state,
        send: send
      )
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }
}
