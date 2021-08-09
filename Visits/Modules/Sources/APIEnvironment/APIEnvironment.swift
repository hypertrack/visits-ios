import ComposableArchitecture
import Types
import Utility


public struct APIEnvironment {
  public var cancelOrder: (Token.Value, DeviceID, Order) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>
  public var completeOrder: (Token.Value, DeviceID, Order) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>
  public var createPlace: (Token.Value, DeviceID, Coordinate, IntegrationEntity) -> Effect<Result<Place, APIError<Token.Expired>>, Never>
  public var getHistory: (Token.Value, DeviceID, Date) -> Effect<Result<History, APIError<Token.Expired>>, Never>
  public var getIntegrationEntities: (Token.Value, Limit, Search) -> Effect<Result<[IntegrationEntity], APIError<Token.Expired>>, Never>
  public var getOrders:  (Token.Value, DeviceID) -> Effect<Result<Set<Order>, APIError<Token.Expired>>, Never>
  public var getPlaces:  (Token.Value, DeviceID) -> Effect<Result<Set<Place>, APIError<Token.Expired>>, Never>
  public var getProfile: (Token.Value, DeviceID) -> Effect<Result<Profile, APIError<Token.Expired>>, Never>
  public var getToken: (PublishableKey, DeviceID) -> Effect<Result<Token.Value, APIError<Never>>, Never>
  public var signIn: (Email, Password) -> Effect<Result<PublishableKey, APIError<CognitoError>>, Never>
  public var updateOrderNote: (Token.Value, DeviceID, Order, Order.Note) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>
  
  public init(
    cancelOrder: @escaping (Token.Value, DeviceID, Order) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>,
    completeOrder: @escaping (Token.Value, DeviceID, Order) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>,
    createPlace: @escaping (Token.Value, DeviceID, Coordinate, IntegrationEntity) -> Effect<Result<Place, APIError<Token.Expired>>, Never>,
    getHistory: @escaping (Token.Value, DeviceID, Date) -> Effect<Result<History, APIError<Token.Expired>>, Never>,
    getIntegrationEntities: @escaping (Token.Value, Limit, Search) -> Effect<Result<[IntegrationEntity], APIError<Token.Expired>>, Never>,
    getOrders: @escaping  (Token.Value, DeviceID) -> Effect<Result<Set<Order>, APIError<Token.Expired>>, Never>,
    getPlaces: @escaping  (Token.Value, DeviceID) -> Effect<Result<Set<Place>, APIError<Token.Expired>>, Never>,
    getProfile: @escaping (Token.Value, DeviceID) -> Effect<Result<Profile, APIError<Token.Expired>>, Never>,
    getToken: @escaping (PublishableKey, DeviceID) -> Effect<Result<Token.Value, APIError<Never>>, Never>,
    signIn: @escaping (Email, Password) -> Effect<Result<PublishableKey, APIError<CognitoError>>, Never>,
    updateOrderNote: @escaping (Token.Value, DeviceID, Order, Order.Note) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never>
  ) {
    self.cancelOrder = cancelOrder
    self.completeOrder = completeOrder
    self.createPlace = createPlace
    self.getHistory = getHistory
    self.getIntegrationEntities = getIntegrationEntities
    self.getOrders = getOrders
    self.getPlaces = getPlaces
    self.getProfile = getProfile
    self.getToken = getToken
    self.signIn = signIn
    self.updateOrderNote = updateOrderNote
  }
}
