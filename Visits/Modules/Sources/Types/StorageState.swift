public struct StorageState: Equatable {
  public enum Flow: Equatable {
    case firstRun
    case signIn(Email?)
    case driverID(DriverID?, PublishableKey)
    case main(Set<Place>, TabSelection, PublishableKey, DriverID)
  }
  
  public var experience: Experience
  public var flow: Flow
  public var locationAlways: LocationAlwaysPermissions
  public var pushStatus: PushStatus
  
  public init(
    experience: Experience,
    flow: Flow,
    locationAlways: LocationAlwaysPermissions,
    pushStatus: PushStatus
  ) {
    self.experience = experience
    self.flow = flow
    self.locationAlways = locationAlways
    self.pushStatus = pushStatus
  }
}

public enum StoredScreen {
  case firstRun
  case signUp
  case signIn
  case driverID
  case main
}

public struct StateRestorationError: Error, Equatable {
  public var driverID: DriverID?
  public var email: Email?
  public var experience: Experience?
  public var locationAlways: LocationAlwaysPermissions?
  public var places: Set<Place>?
  public var publishableKey: PublishableKey?
  public var pushStatus: PushStatus?
  public var screen: StoredScreen?
  public var tabSelection: TabSelection?
  
  public init(
    driverID: DriverID? = nil,
    email: Email? = nil,
    experience: Experience? = nil,
    locationAlways: LocationAlwaysPermissions? = nil,
    places: Set<Place>? = nil,
    publishableKey: PublishableKey? = nil,
    pushStatus: PushStatus? = nil,
    screen: StoredScreen? = nil,
    tabSelection: TabSelection? = nil
  ) {
    self.driverID = driverID
    self.email = email
    self.experience = experience
    self.locationAlways = locationAlways
    self.places = places
    self.publishableKey = publishableKey
    self.pushStatus = pushStatus
    self.screen = screen
    self.tabSelection = tabSelection
  }
}
