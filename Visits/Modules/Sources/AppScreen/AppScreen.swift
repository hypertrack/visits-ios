import BlockerScreen
import ComposableArchitecture
import DriverIDScreen
import LoadingScreen
import MapKit
import MapScreen
import ProfileScreen
import SignInScreen
import SignUpFormScreen
import SignUpQuestionsScreen
import SignUpVerificationScreen
import SummaryScreen
import SwiftUI
import Types
import Views
import VisitScreen
import VisitsScreen

public enum VisitOrVisits: Equatable {
  case visit(VisitScreen.State)
  case visits(VisitsScreen.State)
  
  var credentials: (deviceID: String, publishableKey: String) {
    switch self {
    case let .visit(s):
      return (s.deviceID, s.publishableKey)
    case let .visits(s):
      return (s.deviceID, s.publishableKey)
    }
  }
}

public struct AppScreen: View {
  public enum State {
    case loading
    case signIn(SignInScreen.State)
    case signUpForm(SignUpFormScreen.State)
    case signUpQuestions(SignUpQuestionsScreen.State)
    case signUpVerification(SignUpVerificationScreen.State)
    case driverID(DriverIDScreen.State)
    case blocker(Blocker.State)
    case visits(VisitOrVisits, History?, [MapVisit], DriverID, DeviceID, TabSelection)
  }
  
  public enum Action {
    case signUpForm(SignUpFormScreen.Action)
    case signUpQuestions(SignUpQuestionsScreen.Action)
    case signUpVerification(SignUpVerificationScreen.Action)
    case signIn(SignInScreen.Action)
    case driverID(DriverIDScreen.Action)
    case blocker(Blocker.Action)
    case visits(VisitsScreen.Action)
    case visit(VisitScreen.Action)
    case tab(TabSelection)
    case map(String)
  }
  
  let store: Store<State, Action>
  
  public init(store: Store<State, Action>) { self.store = store }
  
  public var body: some View {
    WithViewStore(store) { viewStore in
      switch viewStore.state {
      case .loading:
        LoadingScreen()
      case let .signUpForm(s):
        SignUpFormScreen(state: s) {
          viewStore.send(.signUpForm($0))
        }
      case let .signUpQuestions(s):
        SignUpQuestionsScreen(state: s) {
          viewStore.send(.signUpQuestions($0))
        }
      case let .signUpVerification(s):
        SignUpVerificationScreen(state: s) {
          viewStore.send(.signUpVerification($0))
        }
      case let .signIn(s):
        SignInScreen(state: s) {
          viewStore.send(.signIn($0))
        }
      case let .driverID(s):
        DriverIDScreen(state: s) {
          viewStore.send(.driverID($0))
        }
      case let .blocker(s):
        Blocker(state: s) {
          viewStore.send(.blocker($0))
        }
      case let .visits(s, h, mv, drID, deID, sel):
        VisitsBlock(
          state: (s, h, mv, drID, deID, sel),
          sendMap: { viewStore.send(.map($0)) },
          sendVisit: { viewStore.send(.visit($0)) },
          sendVisits: { viewStore.send(.visits($0)) },
          sendTab: { viewStore.send(.tab($0)) }
        )
      }
    }
  }
}

struct VisitsBlock: View {
  let state: (
    visits: VisitOrVisits,
    history: History?,
    assignedVisits: [MapVisit],
    driverID: DriverID,
    deviceID: DeviceID,
    tabSelection: TabSelection
  )
  let sendMap: (String) -> Void
  let sendVisit: (VisitScreen.Action) -> Void
  let sendVisits: (VisitsScreen.Action) -> Void
  let sendTab: (TabSelection) -> Void
  
  var body: some View {
    TabView(
      selection: Binding(
        get: { state.tabSelection },
        set: { sendTab($0) }
      )
    ) {
      ZStack() {
        MapScreen(
          polyline: Binding.constant(state.history?.coordinates ?? []),
          sendSelectedMapVisit: sendMap,
          visits: Binding.constant(state.assignedVisits)
        )
        .edgesIgnoringSafeArea(.top)
        .padding([.bottom], state.history?.driveDistance != nil ? state.history?.driveDistance != 0 ? 78 : 0 : 0)
        if let distance = state.history?.driveDistance, distance != 0 {
          VStack {
            Spacer()
            RoundedStack {
              HStack {
                Text("Distance: \(localizedDistance(distance))")
                  .font(.normalHighBold)
                  .padding()
                Spacer()
              }
            }
            .padding(.bottom, -10)
          }
        }
      }
      .tabItem {
        Image(systemName: "map")
        Text("Map")
      }
      .tag(TabSelection.map)
      
      switch state.visits {
      case let .visit(v):
        VisitScreen(state: v) {
          sendVisit($0)
        }
        .tabItem {
          Image(systemName: "list.dash")
          Text("Orders")
        }
        .tag(TabSelection.visits)
      case let .visits(vs):
        VisitsScreen(state: vs) {
          sendVisits($0)
        }
        .tabItem {
          Image(systemName: "list.dash")
          Text("Orders")
        }
        .tag(TabSelection.visits)
      }
      
      SummaryScreen(
        state: .init(
          trackedDuration: state.history?.trackedDuration ?? 0,
          driveDistance: state.history?.driveDistance ?? 0,
          driveDuration: state.history?.driveDuration ?? 0,
          walkSteps: state.history?.walkSteps ?? 0,
          walkDuration: state.history?.walkDuration ?? 0,
          stopDuration: state.history?.stopDuration ?? 0
        )
      )
      .tabItem {
        Image(systemName: "timer")
        Text("Summary")
      }
      .tag(TabSelection.summary)
      
      ProfileScreen(
        state: .init(
          id: state.driverID.rawValue.rawValue,
          name: "",
          deviceID: state.deviceID.rawValue.rawValue,
          metadata: [:],
          appVersion: "2.3.0"
        )
      )
      .tabItem {
        Image(systemName: "person")
        Text("Profile")
      }
      .tag(TabSelection.profile)
    }
  }
}

func localizedDistance(_ distanceMeters: UInt) -> String {
  let formatter = MKDistanceFormatter()
  formatter.unitStyle = .full
  return formatter.string(fromDistance: CLLocationDistance(distanceMeters))
}

extension AppScreen.State: Equatable {}

struct AppScreen_Previews: PreviewProvider {
  static var previews: some View {
    AppScreen(
      store: .init(
        initialState: .visits(
          .visits(
            .init(
              pending: [],
              visited: [],
              completed: [],
              canceled: [],
              isNetworkAvailable: true,
              refreshing: false,
              deviceID: "DeviceID",
              publishableKey: "PublishableKey"
            )
          ),
          .init(
            coordinates: []
          ),
          [
          ],
          "DriverID",
          "DeviceID",
          .map),
        reducer: .empty,
        environment: ()
      )
    )
    .previewScheme(.dark)
  }
}
