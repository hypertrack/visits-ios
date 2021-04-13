import ComposableArchitecture
import Types


public struct APIEnvironment {
  public var getHistory: (PublishableKey, DeviceID, Date) -> Effect<Result<History, APIError<Never>>, Never>
  public var getOrders: (PublishableKey, DeviceID) -> Effect<Result<[APIOrderID: APIOrder], APIError<Never>>, Never>
  public var getPlaces: (PublishableKey, DeviceID) -> Effect<Result<Set<Place>, APIError<Never>>, Never>
  public var resendVerificationCode: (Email) -> Effect<Result<ResendVerificationSuccess, APIError<ResendVerificationError>>, Never>
  public var reverseGeocode: (Coordinate) -> Effect<Address, Never>
  public var signIn: (Email, Password) -> Effect<Result<PublishableKey, APIError<CognitoError>>, Never>
  public var signUp: (BusinessName, Email, Password, BusinessManages, ManagesFor) -> Effect<Result<SignUpSuccess, APIError<CognitoError>>, Never>
  public var verifyEmail: (Email, VerificationCode) -> Effect<Result<PublishableKey, APIError<VerificationError>>, Never>
  
  public init(
    getHistory: @escaping (PublishableKey, DeviceID, Date) -> Effect<Result<History, APIError<Never>>, Never>,
    getOrders: @escaping (PublishableKey, DeviceID) -> Effect<Result<[APIOrderID: APIOrder], APIError<Never>>, Never>,
    getPlaces: @escaping (PublishableKey, DeviceID) -> Effect<Result<Set<Place>, APIError<Never>>, Never>,
    resendVerificationCode: @escaping (Email) -> Effect<Result<ResendVerificationSuccess, APIError<ResendVerificationError>>, Never>,
    reverseGeocode: @escaping (Coordinate) -> Effect<Address, Never>,
    signIn: @escaping (Email, Password) -> Effect<Result<PublishableKey, APIError<CognitoError>>, Never>,
    signUp: @escaping (BusinessName, Email, Password, BusinessManages, ManagesFor) -> Effect<Result<SignUpSuccess, APIError<CognitoError>>, Never>,
    verifyEmail: @escaping (Email, VerificationCode) -> Effect<Result<PublishableKey, APIError<VerificationError>>, Never>
  ) {
    self.getHistory = getHistory
    self.getOrders = getOrders
    self.getPlaces = getPlaces
    self.resendVerificationCode = resendVerificationCode
    self.reverseGeocode = reverseGeocode
    self.signIn = signIn
    self.signUp = signUp
    self.verifyEmail = verifyEmail
  }
}
