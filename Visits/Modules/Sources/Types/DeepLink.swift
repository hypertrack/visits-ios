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
  
  public init(publishableKey: PublishableKey, variant: Variant, url: URL) { self.publishableKey = publishableKey; self.variant = variant; self.url = url }
}
