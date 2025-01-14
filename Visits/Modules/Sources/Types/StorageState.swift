public struct StorageState: Equatable {
  public enum Flow: Equatable {
    case firstRun
    case signIn(Email?)
    case main(TabSelection, PublishableKey, Name, WorkerHandle?)
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
  case signIn
  case main
}

public struct StateRestorationError: Error, Equatable {
  public var name: Name?
  public var email: Email?
  public var experience: Experience?
  public var locationAlways: LocationAlwaysPermissions?
  public var publishableKey: PublishableKey?
  public var pushStatus: PushStatus?
  public var screen: StoredScreen?
  public var tabSelection: TabSelection?
  
  public init(
    name: Name? = nil,
    email: Email? = nil,
    experience: Experience? = nil,
    locationAlways: LocationAlwaysPermissions? = nil,
    publishableKey: PublishableKey? = nil,
    pushStatus: PushStatus? = nil,
    screen: StoredScreen? = nil,
    tabSelection: TabSelection? = nil
  ) {
    self.name = name
    self.email = email
    self.experience = experience
    self.locationAlways = locationAlways
    self.publishableKey = publishableKey
    self.pushStatus = pushStatus
    self.screen = screen
    self.tabSelection = tabSelection
  }
}
