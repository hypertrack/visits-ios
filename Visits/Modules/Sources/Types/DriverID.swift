import NonEmpty
import Tagged

public typealias DriverID = Tagged<DriverIDTag, NonEmptyString>
public enum DriverIDTag {}


public struct DriverIDState: Equatable {
  public var status: Status
  public var publishableKey: PublishableKey
  
  public init(status: DriverIDState.Status, publishableKey: PublishableKey) {
    self.status = status; self.publishableKey = publishableKey
  }
  
  public enum Status: Equatable {
    case entering(DriverID?)
    case entered(DriverID)
  }
}
