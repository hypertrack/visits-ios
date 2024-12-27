import NonEmpty
import SwiftUI
import Types
import Views


public struct VisitsScreen: View {
  public struct State {
    let refreshing: Bool
    
    public init(refreshing: Bool) {
      self.refreshing = refreshing
    }
  }
  public enum Action: Equatable {
    case refresh
    case copyToPasteboard(NonEmptyString)
    case selectVisit(NonEmptyString)
  }
  
  let state: State
  let send: (Action) -> Void
  
  public init(
    state: State,
    send: @escaping (Action) -> Void
  ) {
    self.state = state
    self.send = send
  }
  
  public var body: some View {
    NavigationView {
      VStack {
          VisitsList(visitsToDisplay: [], selected: nil, select: { _ in }, copy: { _ in })
        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
            RefreshButton(state: state.refreshing ? .refreshing : .enabled) {
              send(.refresh)
            }
          }
        }
      }
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }
}
