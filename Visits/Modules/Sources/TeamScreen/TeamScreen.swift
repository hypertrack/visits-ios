import NonEmpty
import SwiftUI
import Types
import Views

public struct TeamScreen: View {
  public struct State {
    let refreshing: Bool
    let team: TeamValue?

    public init(refreshing: Bool, team: TeamValue?) {
      self.refreshing = refreshing
      self.team = team
    }
  }

  public enum Action: Equatable {
    case refresh
    case selectTeamWorker(WorkerHandle)
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
        switch state.team {
        case let .l2Manager(manager):
          TeamList(teamWorkers: getSubordinates(team: manager.subordinates))
        case let .l1Manager(manager):
          TeamList(teamWorkers: getSubordinates(team: manager.subordinates))
        case let .l0Worker(worker):
          Text("You don't have any subordinates")
        case .none:
          Text("No team data available")
        }
      }.toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          RefreshButton(state: state.refreshing ? .refreshing : .enabled) {
            send(.refresh)
          }
        }
      }
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }

  func getSubordinates(team: [TeamValue]) -> [WorkerHandle] {
    return team.flatMap { teamValue in
      switch teamValue {
      case let .l2Manager(manager):
          return [manager.workerHandle] + getSubordinates(team: manager.subordinates)
      case let .l1Manager(manager):
        return [manager.workerHandle] + getSubordinates(team: manager.subordinates) 
      case let .l0Worker(worker):
        return [worker.workerHandle]
      }
    }
  }
}
