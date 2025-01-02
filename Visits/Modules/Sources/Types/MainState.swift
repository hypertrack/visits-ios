import Foundation
import IdentifiedCollections
import Utility

public struct MainState: Equatable {
  public var map: MapState
  public var trip: Trip?
  public var selectedOrderId: Order.ID?
  public var places: PlacesSummary?
  public var placesPresentation: PlacesPresentation
  public var selectedPlace: Place?
  public var addPlace: AddPlace?
  public var history: History?
  public var tab: TabSelection
  public var publishableKey: PublishableKey
  public var profile: Profile
  public var integrationStatus: IntegrationStatus
  public var requests: Set<Request>
  public var selectedTeamWorker: TeamWorkerData?
  public var selectedVisit: PlaceVisit?
  public var team: TeamValue?
  public var token: Token?
  public var visits: VisitsData?
  public var visitsDateFrom: Date
  public var visitsDateTo: Date
  public var workerHandle: WorkerHandle

  public init(
    map: MapState,
    trip: Trip?,
    selectedOrderId: Order.ID? = nil,
    places: PlacesSummary? = nil,
    placesPresentation: PlacesPresentation = .byPlace,
    selectedPlace: Place? = nil,
    addPlace: AddPlace? = nil,
    history: History? = nil,
    tab: TabSelection,
    publishableKey: PublishableKey,
    profile: Profile,
    integrationStatus: IntegrationStatus = .unknown,
    requests: Set<Request> = [],
    selectedTeamWorker: TeamWorkerData? = nil,
    selectedVisit: PlaceVisit? = nil,
    team: TeamValue? = nil,
    token: Token? = nil,
    visits: VisitsData? = nil,
    visitsDateFrom: Date = Date(),
    visitsDateTo: Date = Date(),
    workerHandle: WorkerHandle
  ) {
    self.map = map
    self.trip = trip
    self.selectedOrderId = selectedOrderId
    self.places = places
    self.placesPresentation = placesPresentation
    self.selectedPlace = selectedPlace
    self.addPlace = addPlace
    self.history = history
    self.tab = tab
    self.publishableKey = publishableKey
    self.profile = profile
    self.integrationStatus = integrationStatus
    self.requests = requests
    self.selectedTeamWorker = selectedTeamWorker
    self.selectedVisit = selectedVisit
    self.team = team
    self.token = token
    self.visits = visits
    self.visitsDateFrom = visitsDateFrom
    self.visitsDateTo = visitsDateTo
    self.workerHandle = workerHandle
  }
}
