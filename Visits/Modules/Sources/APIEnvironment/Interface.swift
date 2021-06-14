import ComposableArchitecture
import Types
import Utility


public struct APIEnvironment {
  public var cancelOrder: (PublishableKey, DeviceID, Order) -> Effect<Result<Terminal, APIError<Never>>, Never>
  public var completeOrder: (PublishableKey, DeviceID, Order) -> Effect<Result<Terminal, APIError<Never>>, Never>
  public var getHistory: (PublishableKey, DeviceID, Date) -> Effect<Result<History, APIError<Never>>, Never>
  public var getOrders: (PublishableKey, DeviceID) -> Effect<Result<Set<Order>, APIError<Never>>, Never>
  public var getPlaces: (PublishableKey, DeviceID) -> Effect<Result<Set<Place>, APIError<Never>>, Never>
  public var reverseGeocode: (Coordinate) -> Effect<GeocodedResult, Never>
  public var signIn: (Email, Password) -> Effect<Result<PublishableKey, APIError<CognitoError>>, Never>
  
  public init(
    cancelOrder: @escaping (PublishableKey, DeviceID, Order) -> Effect<Result<Terminal, APIError<Never>>, Never>,
    completeOrder: @escaping (PublishableKey, DeviceID, Order) -> Effect<Result<Terminal, APIError<Never>>, Never>,
    getHistory: @escaping (PublishableKey, DeviceID, Date) -> Effect<Result<History, APIError<Never>>, Never>,
    getOrders: @escaping (PublishableKey, DeviceID) -> Effect<Result<Set<Order>, APIError<Never>>, Never>,
    getPlaces: @escaping (PublishableKey, DeviceID) -> Effect<Result<Set<Place>, APIError<Never>>, Never>,
    reverseGeocode: @escaping (Coordinate) -> Effect<GeocodedResult, Never>,
    signIn: @escaping (Email, Password) -> Effect<Result<PublishableKey, APIError<CognitoError>>, Never>
  ) {
    self.cancelOrder = cancelOrder
    self.completeOrder = completeOrder
    self.getHistory = getHistory
    self.getOrders = getOrders
    self.getPlaces = getPlaces
    self.reverseGeocode = reverseGeocode
    self.signIn = signIn
  }
}
