import Credentials
import DeviceID
import DriverID
import ManualVisitsStatus
import PublishableKey
import SDK
import Visit

public enum StorageState: Equatable {
  case signIn(Email?)
  case driverID(DriverID?, PublishableKey, ManualVisitsStatus?)
  case visits(Visits, PublishableKey, DriverID)
}

public enum RestoredState: Equatable {
  case deepLink
  case signIn(Email?)
  case driverID(DriverID?, PublishableKey, ManualVisitsStatus?)
  case visits(Visits, PublishableKey, DriverID, DeviceID, SDKUnlockedStatus, Permissions)
}
