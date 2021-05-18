import ComposableArchitecture
import Types


public struct APIEnvironment {
  public var getHistory: (PublishableKey, DeviceID, Date) -> Effect<Result<History, APIError<Never>>, Never>
  public var getOrders: (PublishableKey, DeviceID) -> Effect<Result<[APIOrderID: APIOrder], APIError<Never>>, Never>
  public var getPlaces: (PublishableKey, DeviceID) -> Effect<Result<Set<Place>, APIError<Never>>, Never>
  public var reverseGeocode: (Coordinate) -> Effect<GeocodedResult, Never>
  public var signIn: (Email, Password) -> Effect<Result<PublishableKey, APIError<CognitoError>>, Never>
  
  public init(
    getHistory: @escaping (PublishableKey, DeviceID, Date) -> Effect<Result<History, APIError<Never>>, Never>,
    getOrders: @escaping (PublishableKey, DeviceID) -> Effect<Result<[APIOrderID: APIOrder], APIError<Never>>, Never>,
    getPlaces: @escaping (PublishableKey, DeviceID) -> Effect<Result<Set<Place>, APIError<Never>>, Never>,
    reverseGeocode: @escaping (Coordinate) -> Effect<GeocodedResult, Never>,
    signIn: @escaping (Email, Password) -> Effect<Result<PublishableKey, APIError<CognitoError>>, Never>
  ) {
    self.getHistory = getHistory
    self.getOrders = getOrders
    self.getPlaces = getPlaces
    self.reverseGeocode = reverseGeocode
    self.signIn = signIn
  }
}
