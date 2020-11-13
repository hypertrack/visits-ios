import ComposableArchitecture
import Credentials
import DeviceID
import NonEmpty
import Prelude
import PublishableKey
import Visit

public struct APIEnvironment {
  public var getVisits: (PublishableKey, DeviceID) -> Effect<Either<NonEmptySet<AssignedVisit>, NonEmptyString>, Never>
  public var signIn: (Email, Password) -> Effect<Either<PublishableKey, NonEmptyString>, Never>
  
  public init(
    getVisits: @escaping (PublishableKey, DeviceID) -> Effect<Either<NonEmptySet<AssignedVisit>, NonEmptyString>, Never>,
    signIn: @escaping (Email, Password) -> Effect<Either<PublishableKey, NonEmptyString>, Never>
  ) {
    self.getVisits = getVisits
    self.signIn = signIn
  }
}
