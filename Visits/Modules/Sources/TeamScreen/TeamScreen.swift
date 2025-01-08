import NonEmpty
import SwiftUI
import Types
import Views
import VisitsScreen

public struct TeamScreen: View {
  public struct State {
    let refreshing: Bool
    let selected: TeamWorkerData?
    let team: TeamValue?

    public init(refreshing: Bool, selected: TeamWorkerData?, team: TeamValue?) {
      self.refreshing = refreshing
      self.selected = selected
      self.team = team
    }
  }

  public enum Action: Equatable {
    case refresh
    case selectTeamWorker(WorkerHandle?)
    case teamWorkerVisitsAction(VisitsView.Action, WorkerHandle)
  }

  let state: State
  let send: (Action) -> Void

  var navigationLink: NavigationLink<EmptyView, VisitsView>? {
    guard let worker = state.selected else { return nil }

    return NavigationLink(
      destination: VisitsView(
        state: .init(
          from: worker.from,
          refreshing: worker.visits == nil,
          selected: worker.selectedVisit,
          to: worker.to,
          visits: worker.visits,
          workerHandle: worker.workerHandle
        ),
        send: {
          send(.teamWorkerVisitsAction($0, worker.workerHandle))
        }
      ),
      tag: worker.workerHandle,
      selection: .init(
        get: { state.selected?.workerHandle },
        set: { send(.selectTeamWorker($0)) }
      )
    ) {
      EmptyView()
    }
  }

  public init(
    state: State,
    send: @escaping (Action) -> Void
  ) {
    self.state = state
    self.send = send
  }

  public var body: some View {
    NavigationView {
      navigationLink
      VStack {
        switch state.team {
        case let .l2Manager(manager):
          TeamList(
            select: {
              send(.selectTeamWorker($0))
            },
            teamWorkers: getSubordinates(team: manager.subordinates)
          )
        case let .l1Manager(manager):
          TeamList(
            select: {
              send(.selectTeamWorker($0))
            },
            teamWorkers: getSubordinates(team: manager.subordinates)
          )
        case .l0Worker:
          Text("You don't have any subordinates")
        case .noTeamData:
          Text("No team data available")
        case .none:
          Text("Loading")
        }
      }.toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          RefreshButton(state: state.refreshing ? .refreshing : .enabled) {
            send(.refresh)
          }
        }
      }
    }
    .navigationBarHidden(true)
    .navigationViewStyle(StackNavigationViewStyle())
  }

  func getSubordinates(team: [TeamValue]) -> [TeamValue] {
    return team.flatMap { teamValue in
      switch teamValue {
      case let .l2Manager(manager):
        return [teamValue] + getSubordinates(team: manager.subordinates)
      case let .l1Manager(manager):
        return [teamValue] + getSubordinates(team: manager.subordinates)
      case let .l0Worker(worker):
        return [teamValue]
      case .noTeamData:
        return []
      }
    }
  }
}
