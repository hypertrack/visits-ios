import ComposableArchitecture
import Types
import Utility


public struct APIEnvironment {
  public var cancelOrder: (Token.Value, PublishableKey, DeviceID, Order) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>
  public var completeOrder: (Token.Value, PublishableKey, DeviceID, Order) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>
  public var getHistory: (Token.Value, PublishableKey, DeviceID, Date) -> Effect<Result<History, APIError<Token.Expired>>, Never>
  public var getOrders:  (Token.Value, PublishableKey, DeviceID) -> Effect<Result<Set<Order>, APIError<Token.Expired>>, Never>
  public var getPlaces:  (Token.Value, PublishableKey, DeviceID) -> Effect<Result<Set<Place>, APIError<Token.Expired>>, Never>
  public var getToken: (PublishableKey, DeviceID) -> Effect<Result<Token.Value, APIError<Never>>, Never>
  public var reverseGeocode: (Coordinate) -> Effect<GeocodedResult, Never>
  public var signIn: (Email, Password) -> Effect<Result<PublishableKey, APIError<CognitoError>>, Never>
  public var updateOrderNote: (Token.Value, PublishableKey, DeviceID, Order, Order.Note) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>
  
  public init(
    cancelOrder: @escaping (Token.Value, PublishableKey, DeviceID, Order) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>,
    completeOrder: @escaping (Token.Value, PublishableKey, DeviceID, Order) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>,
    getHistory: @escaping (Token.Value, PublishableKey, DeviceID, Date) -> Effect<Result<History, APIError<Token.Expired>>, Never>,
    getOrders: @escaping  (Token.Value, PublishableKey, DeviceID) -> Effect<Result<Set<Order>, APIError<Token.Expired>>, Never>,
    getPlaces: @escaping  (Token.Value, PublishableKey, DeviceID) -> Effect<Result<Set<Place>, APIError<Token.Expired>>, Never>,
    getToken: @escaping (PublishableKey, DeviceID) -> Effect<Result<Token.Value, APIError<Never>>, Never>,
    reverseGeocode: @escaping (Coordinate) -> Effect<GeocodedResult, Never>,
    signIn: @escaping (Email, Password) -> Effect<Result<PublishableKey, APIError<CognitoError>>, Never>,
    updateOrderNote: @escaping (Token.Value, PublishableKey, DeviceID, Order, Order.Note) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>
  ) {
    self.cancelOrder = cancelOrder
    self.completeOrder = completeOrder
    self.getHistory = getHistory
    self.getOrders = getOrders
    self.getPlaces = getPlaces
    self.getToken = getToken
    self.reverseGeocode = reverseGeocode
    self.signIn = signIn
    self.updateOrderNote = updateOrderNote
  }
}
