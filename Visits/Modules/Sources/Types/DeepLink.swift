import Foundation
import Utility


public struct DeepLink: Equatable {
  public let publishableKey: PublishableKey
  public let variant: Variant
  public let url: URL
  
  public enum Variant: Equatable {
    case old(DriverID)
    case new(These<Email, PhoneNumber>, JSON.Object)
    case driverHandle(DriverHandle, JSON.Object)
  }
    
  public var workerHandle: WorkerHandle {
    return WorkerHandle("ram@hypertrack.io")

    // switch variant {
    // case let .old( driverID):
    //     return WorkerHandle(driverID.rawValue)
    // case let .new(.this(v), _):
    //     return WorkerHandle(v.rawValue)
    // case let .new(.that(v), _):
    //     return WorkerHandle(v.rawValue)
    // case let .new(.both(email, _), _):
    //     return WorkerHandle(email.rawValue)
    // case let .driverHandle(driverHandle, _):
    //   return WorkerHandle(driverHandle.rawValue)
    // }
  }
  
  public init(publishableKey: PublishableKey, variant: Variant, url: URL) { self.publishableKey = publishableKey; self.variant = variant; self.url = url }
}
