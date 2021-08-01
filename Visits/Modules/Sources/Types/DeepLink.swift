import Utility


public struct DeepLink: Equatable {
  public let publishableKey: PublishableKey
  public let variant: Variant
  
  public enum Variant: Equatable {
    case old(DriverID)
    case new(These<Email, PhoneNumber>, JSON.Object)
  }
  
  public init(publishableKey: PublishableKey, variant: Variant) { self.publishableKey = publishableKey; self.variant = variant }
}
