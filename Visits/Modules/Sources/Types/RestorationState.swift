public enum StorageState: Equatable {
  case signIn(Email?)
  case signUp(Email?)
  case driverID(DriverID?, PublishableKey)
  case main(Set<Order>, Set<Place>, TabSelection, PublishableKey, DriverID, PushStatus, Experience)
}

public enum RestoredState: Equatable {
  case deepLink
  case signIn(Email?)
  case signUp(Email?)
  case driverID(DriverID?, PublishableKey)
  case main(Set<Order>, Set<Place>, TabSelection, PublishableKey, DriverID, DeviceID, SDKUnlockedStatus, PushStatus, Permissions, Experience)
}
