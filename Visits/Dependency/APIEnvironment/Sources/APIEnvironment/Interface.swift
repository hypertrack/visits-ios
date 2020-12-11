import ComposableArchitecture
import Coordinate
import Credentials
import DeviceID
import History
import NonEmpty
import Prelude
import PublishableKey
import Visit


public struct APIEnvironment {
  public var getHistory: (PublishableKey, DeviceID, Date) -> Effect<Either<History, NonEmptyString>, Never>
  public var getVisits: (PublishableKey, DeviceID) -> Effect<Either<NonEmptySet<AssignedVisit>, NonEmptyString>, Never>
  public var reverseGeocode: ([Coordinate]) -> Effect<[(Coordinate, These<AssignedVisit.Street, AssignedVisit.FullAddress>?)], Never>
  public var signIn: (Email, Password) -> Effect<Either<PublishableKey, NonEmptyString>, Never>
  
  public init(
    getHistory: @escaping (PublishableKey, DeviceID, Date) -> Effect<Either<History, NonEmptyString>, Never>,
    getVisits: @escaping (PublishableKey, DeviceID) -> Effect<Either<NonEmptySet<AssignedVisit>, NonEmptyString>, Never>,
    reverseGeocode: @escaping ([Coordinate]) -> Effect<[(Coordinate, These<AssignedVisit.Street, AssignedVisit.FullAddress>?)], Never>,
    signIn: @escaping (Email, Password) -> Effect<Either<PublishableKey, NonEmptyString>, Never>
  ) {
    self.getHistory = getHistory
    self.getVisits = getVisits
    self.reverseGeocode = reverseGeocode
    self.signIn = signIn
  }
}
