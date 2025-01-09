import AddPlaceView
import BlockerScreen
import ComposableArchitecture
import LoadingScreen
import MapKit
import MapScreen
import OrderScreen
import OrdersListScreen
import PlacesScreen
import ProfileScreen
import SignInScreen
import SummaryScreen
import SwiftUI
import TeamScreen
import TripScreen
import Types
import Views
import VisitsScreen

public struct AppScreen: View {
  public struct State {
    public var screen: Screen
    public var errorAlert: AlertState<ErrorAlertAction>?
    public var errorReportingAlert: AlertState<SendErrorReportAction>?

    public init(
      screen: AppScreen.Screen,
      errorAlert: AlertState<ErrorAlertAction>? = nil,
      errorReportingAlert: AlertState<SendErrorReportAction>? = nil
    ) {
      self.screen = screen
      self.errorAlert = errorAlert
      self.errorReportingAlert = errorReportingAlert
    }
  }

  public enum Screen {
    case loading
    case signIn(SignInState)
    case blocker(Blocker.State)
    case main(MainBlockState)
    case addPlace(AddPlace, Set<Place>)
  }

  public enum Action {
    case addPlace(AddPlaceView.Action)
    case signIn(SignInScreenAction)
    case blocker(Blocker.Action)
    case orders(OrdersListScreenAction)
    case order(OrderScreen.Action)
    case places(PlacesScreen.Action)
    case profile(ProfileScreen.Action)
    case tab(TabSelection)
    case visits(VisitsView.Action)
    case map(MapView.Action)
    case team(TeamScreen.Action)
    case errorAlert(ErrorAlertAction)
    case errorReportingAlert(SendErrorReportAction)
  }

  let store: Store<State, Action>

  public init(store: Store<State, Action>) { self.store = store }

  public var body: some View {
    WithViewStore(store) { viewStore in
      Group {
        switch viewStore.state.screen {
        case .loading:
          LoadingScreen()
        case let .signIn(s):
          if #available(iOS 15.0, *) {
            SignInScreen(state: s) {
              viewStore.send(.signIn($0))
            }
          } else {
            SignInScreeniOS14(state: s) {
              viewStore.send(.signIn($0))
            }
          }
        case let .blocker(s):
          Blocker(state: s) {
            viewStore.send(.blocker($0))
          }
        case let .main(s):
          MainBlock(
            state: s,
            sendMap: { viewStore.send(.map($0)) },
            sendOrder: { viewStore.send(.order($0)) },
            sendOrders: { viewStore.send(.orders($0)) },
            sendPlaces: { viewStore.send(.places($0)) },
            sendProfile: { viewStore.send(.profile($0)) },
            sendTab: { viewStore.send(.tab($0)) },
            sendVisits: { viewStore.send(.visits($0)) },
            sendTeam: { viewStore.send(.team($0)) }
          )
        case let .addPlace(adding, places):
          AddPlaceView(
            store: store.scope(
              state: { state in
                .init(adding: adding, places: places)
              },
              action: (/Action.addPlace).embed
            )
          )
        }
      }
      .modifier(let: viewStore.errorAlert) { view, _ in
        view.alert(self.store.scope(state: \.errorAlert, action: AppScreen.Action.errorAlert), dismiss: ErrorAlertAction.ok)
      }
      .modifier(let: viewStore.errorReportingAlert) { view, _ in
        view.alert(self.store.scope(state: \.errorReportingAlert, action: AppScreen.Action.errorReportingAlert), dismiss: SendErrorReportAction.no)
      }
    }
  }
}

public struct MainBlockState: Equatable {
  public let mapState: MapState
  public let placesSummary: PlacesSummary?
  public let selectedPlace: Place?
  public let placesPresentation: PlacesPresentation
  public let requests: Set<Request>
  public let history: History?
  public let trip: Trip?
  public let selectedOrderId: Order.ID?
  public let profile: Profile
  public let integrationStatus: IntegrationStatus
  public let deviceID: DeviceID
  public let sdkStatus: SDKStatus
  public let selectedTeamWorker: TeamWorkerData?
  public let selectedVisit: PlaceVisit?
  public let tabSelection: TabSelection
  public let team: TeamValue?
  public let version: AppVersion
  public let visits: VisitsData?
  public let visitsDateFrom: Date
  public let visitsDateTo: Date
  public let workerHandle: WorkerHandle
  public let publishableKey: PublishableKey

  public init(mapState: MapState,
              placesSummary: PlacesSummary?,
              selectedPlace: Place?,
              placesPresentation: PlacesPresentation,
              requests: Set<Request>,
              history: History?,
              trip: Trip?,
              selectedOrderId: Order.ID?,
              profile: Profile,
              integrationStatus: IntegrationStatus,
              deviceID: DeviceID,
              sdkStatus: SDKStatus,
              selectedTeamWorker: TeamWorkerData?,
              selectedVisit: PlaceVisit?,
              tabSelection: TabSelection,
              team: TeamValue?,
              version: AppVersion,
              visits: VisitsData?,
              visitsDateFrom: Date,
              visitsDateTo: Date,
              workerHandle: WorkerHandle,
              publishableKey: PublishableKey)
  {
    self.mapState = mapState
    self.placesSummary = placesSummary
    self.selectedPlace = selectedPlace
    self.placesPresentation = placesPresentation
    self.requests = requests
    self.history = history
    self.trip = trip
    self.selectedOrderId = selectedOrderId
    self.profile = profile
    self.integrationStatus = integrationStatus
    self.deviceID = deviceID
    self.sdkStatus = sdkStatus
    self.selectedTeamWorker = selectedTeamWorker
    self.selectedVisit = selectedVisit
    self.tabSelection = tabSelection
    self.team = team
    self.version = version
    self.visits = visits
    self.visitsDateFrom = visitsDateFrom
    self.visitsDateTo = visitsDateTo
    self.workerHandle = workerHandle
    self.publishableKey = publishableKey
  }
}

struct MainBlock: View {
  let state: MainBlockState
  let sendMap: (MapView.Action) -> Void
  let sendOrder: (OrderScreen.Action) -> Void
  let sendOrders: (OrdersListScreenAction) -> Void
  let sendPlaces: (PlacesScreen.Action) -> Void
  let sendProfile: (ProfileScreen.Action) -> Void
  let sendTab: (TabSelection) -> Void
  let sendVisits: (VisitsView.Action) -> Void
  let sendTeam: (TeamScreen.Action) -> Void

  var body: some View {
    TabView(
      selection: Binding(
        get: { state.tabSelection },
        set: { sendTab($0) }
      )
    ) {
      let isLeadschoolOrTeamAccount = state.publishableKey.rawValue.starts(with: "w2eZTj") || state.publishableKey.rawValue.starts(with: "uvIAA8")
      ZStack {
        MapView(
          state: .init(
            autoZoom: state.mapState.autoZoom,
            clockedIn: state.sdkStatus.isRunning,
            orders: state.trip?.orders ?? IdentifiedArrayOf<Order>(),
            places: state.placesSummary?.places ?? [],
            polyline: state.history?.coordinates ?? []
          ),
          send: sendMap
        )
        .edgesIgnoringSafeArea(.top)
        .padding([.bottom], state.history?.driveDistance != nil ? state.history?.driveDistance != 0 ? 40 : 0 : 0)
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
        Image(systemName: "map.fill")
        Text("Map")
      }
      .tag(TabSelection.map)

      VisitsScreen(
        state: .init(
          from: state.visitsDateFrom,
          refreshing: state.visits == nil,
          selected: state.selectedVisit,
          to: state.visitsDateTo,
          visits: state.visits,
          workerHandle: state.workerHandle
        ),
        send: sendVisits
      )
      .tabItem {
        Image(systemName: "location.circle.fill")
        Text("Visits")
      }
      .tag(TabSelection.visits)

      PlacesScreen(
        state: .init(
          places: state.placesSummary,
          selected: state.selectedPlace,
          presentation: state.placesPresentation,
          refreshing: state.requests.contains(Request.placesAndVisits),
          integrationStatus: state.integrationStatus,
          coordinates: state.history?.coordinates ?? []
        ),
        send: sendPlaces
      )
      .tabItem {
        Image(systemName: "mappin.circle.fill")
        Text("Places")
      }
      .tag(TabSelection.places)

      if isLeadschoolOrTeamAccount {
        TeamScreen(
          state: .init(
            refreshing: state.team == nil,
            selected: state.selectedTeamWorker,
            team: state.team,
            workerHandle: state.workerHandle
          ),
          send: sendTeam
        )
        .tabItem {
          Image(systemName: "person.2.circle.fill")
          Text("Team")
        }
        .tag(TabSelection.team)
      }

      if !isLeadschoolOrTeamAccount {
        TripScreen(state: .init(
          clockedIn: state.sdkStatus.isRunning,
          trip: state.trip,
          selected: state.selectedOrderId,
          refreshing: state.requests.contains(Request.oldestActiveTrip)
        ),
                   send: sendOrders,
                   sendOrderAction: sendOrder)
          .tabItem {
            Image(systemName: "checkmark.square.fill")
            Text("Orders")
          }
          .tag(TabSelection.orders)
      }

      ProfileScreen(
        state: .init(
          profile: state.profile,
          deviceID: state.deviceID,
          integrationStatus: state.integrationStatus,
          appVersion: state.version
        ),
        send: sendProfile
      )
      .tabItem {
        Image(systemName: "person.fill")
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
extension AppScreen.Screen: Equatable {}
