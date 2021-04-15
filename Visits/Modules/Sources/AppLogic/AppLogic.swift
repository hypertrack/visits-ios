import APIEnvironment
import AppArchitecture
import BranchEnvironment
import Combine
import ComposableArchitecture
import DeepLinkLogic
import ErrorAlertLogic
import HapticFeedbackEnvironment
import HyperTrackEnvironment
import MapEnvironment
import NetworkEnvironment
import NonEmpty
import PasteboardEnvironment
import Prelude
import PushEnvironment
import StateRestorationEnvironment
import Tagged
import Types
import UIKit

// MARK: - State


public struct AppState: Equatable {
  public var network: Network
  public var flow: AppFlow
  public var alert: AlertState<ErrorAlertAction>?
  
  public static let initialState = AppState(network: .offline, flow: .created, alert: nil)
}

public enum AppFlow: Equatable {
  case created
  case appLaunching
  case firstRun
  case noMotionServices
  case signUp(SignUpState)
  case signIn(SignIn)
  case driverID(DriverID?, PublishableKey)
  case main(Set<Order>, Order?, Set<Place>, History?, TabSelection, PublishableKey, DriverID, DeviceID, SDKUnlockedStatus, Permissions, Refreshing, PushStatus, Experience)
}

public struct GeocodedResult: Equatable {
  let coordinate: Coordinate
  let address: Address
}

// MARK: - Action

public enum AppAction: Equatable {
  // App
  case appHandleSDKLocked
  case appHandleSDKUnlocked(PublishableKey, DriverID, DeviceID, SDKUnlockedStatus, Permissions)
  case appHandleDriverIDFlow(PublishableKey)
  case appHandleFirstRunFlow
  case appHandleSignUpWith(Email?)
  case appHandleSignInWith(Email?)
  // OS
  case copyToPasteboard(NonEmptyString)
  case osFinishedLaunching
  case willEnterForeground
  // Sign Up
  //   Form
  case focusBusinessName
  case businessNameChanged(BusinessName?)
  case completeSignUpForm
  case goToSignIn
  //   Questions
  case businessManagesSelected
  case managesForSelected
  case businessManagesChanged(BusinessManages?)
  case managesForChanged(ManagesFor?)
  case signUp
  case signedUp(Result<SignUpSuccess, APIError<CognitoError>>)
  case cancelSignUp
  //   Verification
  case firstVerificationFieldChanged(String)
  case secondVerificationFieldChanged(String)
  case thirdVerificationFieldChanged(String)
  case fourthVerificationFieldChanged(String)
  case fifthVerificationFieldChanged(String)
  case sixthVerificationFieldChanged(String)
  case deleteVerificationDigit
  case focusVerification
  case resendVerificationCode
  case verificationExtractedFromPasteboard(VerificationCode)
  case verificationPasteboardChanged
  case autoSignInFailed(APIError<CognitoError>)
  // Sign In
  case goToSignUp
  case cancelSignIn
  case emailChanged(Email?)
  case focusEmail
  case focusPassword
  case passwordChanged(Password?)
  case signIn
  case signedIn(Result<PublishableKey, APIError<CognitoError>>)
  // DriverID
  case driverIDChanged(DriverID?)
  case setDriverID
  // Orders
  case selectOrder(String)
  case updateOrders
  // Order
  case cancelOrder
  case checkOutOrder
  case orderNoteChanged(NonEmptyString?)
  case deselectOrder
  case focusOrderNote
  case openAppleMaps
  case pickUpOrder
  case reverseGeocoded([GeocodedResult])
  case ordersUpdated(Result<[APIOrderID: APIOrder], APIError<Never>>)
  // Places
  case placesUpdated(Result<Set<Place>, APIError<Never>>)
  case updatePlaces
  // TabView
  case switchToOrders
  case switchToPlaces
  case switchToMap
  case switchToSummary
  case switchToProfile
  // History
  case historyUpdated(Result<History, APIError<Never>>)
  // Generic UI
  case dismissFocus
  // Deeplink
  case deepLinkOpened(NSUserActivity)
  case deepLinkFirstRunWaitingComplete
  // SDK
  case madeSDK(SDKStatus, Permissions)
  case openSettings
  case requestLocationPermissions
  case requestMotionPermissions
  case statusUpdated(SDKStatus, Permissions)
  case startTracking
  case stopTracking
  // Push
  case receivedPushNotification
  case requestPushAuthorization
  case userHandledPushAuthorization
  // Network
  case network(Network)
  // State
  case restoredState(Either<RestoredState, UntrackableReason>, Network)
  case stateRestored
  // Alert
  case errorAlert(ErrorAlertAction)
}

// MARK: - Environment

public struct AppEnvironment {
  public var api: APIEnvironment
  public var deepLink: BranchEnvironment
  public var hapticFeedback: HapticFeedbackEnvironment
  public var hyperTrack: HyperTrackEnvironment
  public var maps: MapEnvironment
  public var network: NetworkEnvironment
  public var pasteboard: PasteboardEnvironment
  public var push: PushEnvironment
  public var stateRestoration: StateRestorationEnvironment
  
  public init(
    api: APIEnvironment,
    deepLink: BranchEnvironment,
    hapticFeedback: HapticFeedbackEnvironment,
    hyperTrack: HyperTrackEnvironment,
    maps: MapEnvironment,
    network: NetworkEnvironment,
    pasteboard: PasteboardEnvironment,
    push: PushEnvironment,
    stateRestoration: StateRestorationEnvironment
  ) {
    self.api = api
    self.deepLink = deepLink
    self.hapticFeedback = hapticFeedback
    self.hyperTrack = hyperTrack
    self.maps = maps
    self.network = network
    self.pasteboard = pasteboard
    self.push = push
    self.stateRestoration = stateRestoration
  }
}

// MARK: - Reducer

let networkReducer: Reducer<Network, AppAction, Void> = .toggleReducer(.online, .network(.online), .offline, .network(.offline))

struct RefreshingOrdersID: Hashable {}
struct RefreshingHistoryID: Hashable {}
struct RefreshingPlacesID: Hashable {}

let getOrdersEffect = { (
  getOrders: Effect<Result<[APIOrderID: APIOrder], APIError>, Never>,
  mainQueue: AnySchedulerOf<DispatchQueue>
) in
  getOrders
    .receive(on: mainQueue)
    .eraseToEffect()
    .cancellable(id: RefreshingOrdersID())
    .map(AppAction.ordersUpdated)
}

func getPlacesEffect(
  _ getPlaces: Effect<Result<Set<Place>, APIError<Never>>, Never>,
  _ reverseGeocode: @escaping (Coordinate) -> Effect<Address, Never>,
  _ mainQueue: AnySchedulerOf<DispatchQueue>
) -> Effect<AppAction, Never> {
  getPlaces
    .receive(on: mainQueue)
    .eraseToEffect()
    .cancellable(id: RefreshingPlacesID())
    .flatMap { (result: Result<Set<Place>, APIError<Never>>) -> Effect<AppAction, Never> in
      switch result {
      case let .success(places):
        return reverseGeocodePlaces(
          places: Array(places),
          coordinateKeyPath: \Place.shape.centerCoordinate,
          addressLens: ^\Place.address,
          reverseGeocode: reverseGeocode
        )
        .map(Set.init)
        .map { AppAction.placesUpdated(.success($0)) }
      case let .failure(error):
        return Effect(value: AppAction.placesUpdated(.failure(error)))
      }
    }
    .eraseToEffect()
}

func reverseGeocodePlaces<P>(
  places: [P],
  coordinateKeyPath: KeyPath<P, Coordinate>,
  addressLens: Lens<P, Address>,
  reverseGeocode: @escaping (Coordinate) -> Effect<Address, Never>
) -> Effect<[P], Never> {
  places.publisher
    .flatMap { place in
      reverseGeocode(place[keyPath: coordinateKeyPath])
        .map { (address: Address) -> P in
          place |> addressLens *< address
        }
    }
    .collect()
    .eraseToEffect()
}


let getHistoryEffect = { (
  getHistory: Effect<Result<History, APIError>, Never>,
  mainQueue: AnySchedulerOf<DispatchQueue>
) in
  getHistory
  .receive(on: mainQueue)
  .eraseToEffect()
  .cancellable(id: RefreshingHistoryID())
  .map(AppAction.historyUpdated)
}

func over4<A, B, C, D, E, Z>(_ f: @escaping (D) -> Z) -> ((A, B, C, D, E)) -> (A, B, C, Z, E) {
  { ($0.0, $0.1, $0.2, f($0.3), $0.4) }
}

func over1<A, B, C, D, E, Z>(_ f: @escaping (A) -> Z) -> ((A, B, C, D, E)) -> (Z, B, C, D, E) {
  { (f($0.0), $0.1, $0.2, $0.3, $0.4) }
}

func view5<A, B, C, D, E, F, G, H, I, J, K, L, M>(_ t: (A, B, C, D, E, F, G, H, I, J, K, L, M)) -> E { t.4 }
func view12<A, B, C, D, E, F, G, H, I, J, K, L, M>(_ t: (A, B, C, D, E, F, G, H, I, J, K, L, M)) -> L { t.11 }
func view13<A, B, C, D, E, F, G, H, I, J, K, L, M>(_ t: (A, B, C, D, E, F, G, H, I, J, K, L, M)) -> M { t.12 }


public let appReducer: Reducer<AppState, AppAction, SystemEnvironment<AppEnvironment>> = Reducer.combine(
  networkReducer.pullback(state: \.network, action: .self, environment: constant(())),
  deepLinkReducer.pullback(state: deepLinkStateAffine, action: deepLinkActionAffine, environment: toDeepLinkEnvironment),
  errorAlertReducer.pullback(state: errorAlertStateLens.toAffine(), action: errorAlertActionPrism.toAffine(), environment: constant(())),
  stateRestorationReducer,
  Reducer { state, action, environment in
    switch action {
    case .appHandleSDKLocked:
      state.flow = .noMotionServices
      return .none
    case let .appHandleSDKUnlocked(publishableKey, driverID, deviceID, unlockedStatus, permissions):
      let selectedTab = (state.flow *^? /AppFlow.main <¡> view5) ?? .defaultTab
      let dialogSplash = (state.flow *^? /AppFlow.main <¡> view12) ?? .dialogSplash(.notShown)
      let experience   = (state.flow *^? /AppFlow.main <¡> view13) ?? .firstRun
      state.flow = .main([], nil, [], nil, selectedTab, publishableKey, driverID, deviceID, unlockedStatus, permissions, .all, dialogSplash, experience)
      return .merge(
        getOrdersEffect(environment.api.getOrders(publishableKey, deviceID), environment.mainQueue),
        getPlacesEffect(environment.api.getPlaces(publishableKey, deviceID), environment.api.reverseGeocode, environment.mainQueue),
        getHistoryEffect(environment.api.getHistory(publishableKey, deviceID, environment.date()), environment.mainQueue)
      )
    case let .appHandleDriverIDFlow(pk):
      state.flow = .driverID(nil, pk)
      return .none
    case .appHandleFirstRunFlow:
      state.flow = .signUp(.formFilling(nil, nil, nil, nil, nil))
      return .none
    case let .appHandleSignInWith(e):
      state.flow = .signIn(.editingCredentials(e, nil, nil, nil))
      return .none
    case let .appHandleSignUpWith(e):
      state.flow = .signUp(.formFilling(nil, e, nil, nil, nil))
      return .none
    default:
      return .none
    }
  },
  // Sign Up
  Reducer { state, action, environment in
    struct SignUpID: Hashable {}
    struct VerifyID: Hashable {}
    struct ResendVerificationID: Hashable {}
    struct VerificationPasteboardSubscriptionID: Hashable {}
    
    func makeSDK(_ driverID: DriverID) -> (PublishableKey) -> Effect<AppAction, Never> {
      { publishableKey in
        environment.hyperTrack
          .makeSDK(publishableKey)
          .receive(on: environment.mainQueue)
          .flatMap { (status: SDKStatus, permissions: Permissions) -> Effect<AppAction, Never> in
            switch status {
            case .locked:
              return .merge(
                Effect(value: AppAction.appHandleSDKLocked),
                .cancel(id: VerificationPasteboardSubscriptionID())
              )
            case let .unlocked(deviceID, unlockedStatus):
              return .merge(
                .cancel(id: VerificationPasteboardSubscriptionID()),
                Effect(value: AppAction.appHandleSDKUnlocked(publishableKey, driverID, deviceID, unlockedStatus, permissions)),
                environment.hyperTrack
                  .subscribeToStatusUpdates()
                  .receive(on: environment.mainQueue)
                  .eraseToEffect()
                  .map(AppAction.statusUpdated),
                environment.hyperTrack
                  .setDriverID(driverID)
                  .receive(on: environment.mainQueue)
                  .eraseToEffect()
                  .fireAndForget()
              )
            }
          }
          .eraseToEffect()
      }
    }
    
    let checkVerificationCode = environment.pasteboard
      .verificationCodeFromPasteboard()
      .receive(on: environment.mainQueue)
      .flatMap { (code: VerificationCode?) -> Effect<AppAction, Never> in
        switch code {
        case .none:           return .none
        case let .some(code): return Effect(value: AppAction.verificationExtractedFromPasteboard(code))
        }
      }
      .eraseToEffect()
    
    func verify(email: Email, password: Password, code: VerificationCode) -> Effect<AppAction, Never> {
      environment.api
        .verifyEmail(email, code)
        .receive(on: environment.mainQueue)
        .flatMap { (result: Result<PublishableKey, APIError<VerificationError>>) -> Effect<AppAction, Never> in
                    
          let makeSDKBaked = makeSDK(DriverID(rawValue: email.rawValue))
          
          switch result {
          case let .success(pk):
            return makeSDKBaked(pk)
          case .failure(.error(.alreadyVerified)):
            return environment.api
              .signIn(email, password)
              .receive(on: environment.mainQueue)
              .eraseToEffect()
              .flatMap { (result: Result<PublishableKey, APIError<CognitoError>>) -> Effect<AppAction, Never> in
                switch result {
                case let .success(pk):
                  return makeSDKBaked(pk)
                case let .failure(error):
                  return Effect(value: AppAction.autoSignInFailed(error))
                }
              }
              .eraseToEffect()
          case let .failure(.error(.error(cognitoError))):
            return Effect(value: AppAction.autoSignInFailed(.error(cognitoError)))
          case let .failure(.network(network)):
            return Effect(value: AppAction.autoSignInFailed(.network(network)))
          case let .failure(.unknown(urlError)):
            return Effect(value: AppAction.autoSignInFailed(.unknown(urlError)))
          case let .failure(.api(e)):
            return Effect(value: AppAction.autoSignInFailed(.api(e)))
          case let .failure(.server(e)):
            return Effect(value: AppAction.autoSignInFailed(.server(e)))
          }
        }
        .eraseToEffect()
        .cancellable(id: VerifyID(), cancelInFlight: true)
    }
    
    
    switch (state.flow, action) {
    
    case let (.signUp(.formFilled(_, _, _, f, _)), .focusBusinessName):
      state.flow = (state.flow |> (/AppFlow.signUp ** /SignUpState.formFilled) *~? over4(constant(.name))) ?? state.flow
      return .none
    case let (.signUp(.formFilled(_, _, _, f, _)), .focusEmail) where f != .email:
      state.flow = (state.flow |> (/AppFlow.signUp ** /SignUpState.formFilled) *~? over4(constant(.email))) ?? state.flow
      return .none
    case let (.signUp(.formFilled(_, _, _, f, _)), .focusPassword) where f != .password:
      state.flow = (state.flow |> (/AppFlow.signUp ** /SignUpState.formFilled) *~? over4(constant(.password))) ?? state.flow
      return .none
    case (.signUp(.formFilled), .dismissFocus):
      state.flow = (state.flow |> (/AppFlow.signUp ** /SignUpState.formFilled) *~? over4(constant(nil))) ?? state.flow
      return .none
    case let (.signUp(.formFilled(n, e, p, f, er)), .businessNameChanged(newName)):
      if let newName = newName {
        state.flow = (state.flow |> (/AppFlow.signUp ** /SignUpState.formFilled) *~? over1(constant(newName))) ?? state.flow
      } else {
        state.flow = .signUp(.formFilling(nil, e, p, f, er))
      }
      return .none
    case let (.signUp(.formFilled(n, e, p, f, er)), .emailChanged(newEmail)):
      let newEmail = newEmail.flatMap { $0.cleanup() }
      if let newEmail = newEmail, newEmail.isValid() {
        state.flow = .signUp(.formFilled(n, newEmail, p, f, er))
      } else {
        state.flow = .signUp(.formFilling(n, newEmail, p, f, er))
      }
      return .none
    case let (.signUp(.formFilled(n, e, p, f, er)), .passwordChanged(newPassword)):
      if let newPassword = newPassword, newPassword.isValid() {
        state.flow = .signUp(.formFilled(n, e, newPassword, f, er))
      } else {
        state.flow = .signUp(.formFilling(n, e, newPassword, f, er))
      }
      return .none
    case let (.signUp(.formFilling(n, e, p, f, er)), .completeSignUpForm):
      switch (n, e, p) {
      case (.none, _, _):
        state.flow = .signUp(.formFilling(n, e, p, f, "Business name required"))
      case (_, .none, _):
        state.flow = .signUp(.formFilling(n, e, p, f, "Please enter a valid email ID"))
      case let (_, .some(e), _) where !e.isValid():
        state.flow = .signUp(.formFilling(n, e, p, f, "Please enter a valid email ID"))
      case (_, _, .none):
        state.flow = .signUp(.formFilling(n, e, p, f, "Password should be 8 characters or more"))
      case let (_, _, .some(p)) where !p.isValid():
        state.flow = .signUp(.formFilling(n, e, p, f, "Password should be 8 characters or more"))
      case let (.some(n), .some(e), .some(p)):
        state.flow = .signUp(.questions(n, e, p, .answering(nil, .left(.businessManages))))
      }
      return .none
    case let (.signUp(.formFilled(n, e, p, _, _)), .completeSignUpForm):
      state.flow = .signUp(.questions(n, e, p, .answering(nil, .left(.businessManages))))
      return .none
    case let (.signUp(.formFilled(_, e, _, _, _)), .goToSignIn):
      state.flow = .signIn(.editingCredentials(e, nil, nil, nil))
      return .none
      
    case let (.signUp(.formFilling(_, _, _, f, _)), .focusBusinessName):
      state.flow = (state.flow |> (/AppFlow.signUp ** /SignUpState.formFilling) *~? over4(constant(.name))) ?? state.flow
      return .none
    case let (.signUp(.formFilling(_, _, _, f, _)), .focusEmail) where f != .email:
      state.flow = (state.flow |> (/AppFlow.signUp ** /SignUpState.formFilling) *~? over4(constant(.email))) ?? state.flow
      return .none
    case let (.signUp(.formFilling(_, _, _, f, _)), .focusPassword) where f != .password:
      state.flow = (state.flow |> (/AppFlow.signUp ** /SignUpState.formFilling) *~? over4(constant(.password))) ?? state.flow
      return .none
    case (.signUp(.formFilling), .dismissFocus):
      state.flow = (state.flow |> (/AppFlow.signUp ** /SignUpState.formFilling) *~? over4(constant(nil))) ?? state.flow
      return .none
    case let (.signUp(.formFilling(n, e, p, f, er)), .businessNameChanged(newName)):
      if let newName = newName, let p = p, let e = e, e.isValid(), p.isValid() {
        state.flow = .signUp(.formFilled(newName, e, p, f, er))
      } else {
        state.flow = .signUp(.formFilling(newName, e, p, f, er))
      }
      return .none
    case let (.signUp(.formFilling(n, e, p, f, er)), .emailChanged(newEmail)):
      let newEmail = newEmail.flatMap { $0.cleanup() }
      if let newEmail = newEmail, let p = p, let n = n, newEmail.isValid(), p.isValid() {
        state.flow = .signUp(.formFilled(n, newEmail, p, f, er))
      } else {
        state.flow = .signUp(.formFilling(n, newEmail, p, f, er))
      }
      return .none
    case let (.signUp(.formFilling(n, e, p, f, er)), .passwordChanged(newPassword)):
      if let newPassword = newPassword, let e = e, let n = n, e.isValid(), newPassword.isValid() {
        state.flow = .signUp(.formFilled(n, e, newPassword, f, er))
      } else {
        state.flow = .signUp(.formFilling(n, e, newPassword, f, er))
      }
      return .none
    case let (.signUp(.formFilling(_, e, _, _, _)), .goToSignIn):
      return Effect(value: .appHandleSignInWith(e))
    case let (.signUp(.questions(n, e, p, _)), .goToSignUp):
      state.flow = .signUp(.formFilled(n, e, p, .none, .none))
      return .none
    case let (.signUp(.questions(n, e, p, .signingUp(bm, mf, .notSent(_, er)))), .businessManagesSelected):
      state.flow = .signUp(.questions(n, e, p, .signingUp(bm, mf, .notSent(.businessManages, er))))
      return .none
    case let (.signUp(.questions(n, e, p, .signingUp(bm, mf, .notSent(_, er)))), .managesForSelected):
      state.flow = .signUp(.questions(n, e, p, .signingUp(bm, mf, .notSent(.managesFor, er))))
      return .none
    case let (.signUp(.questions(n, e, p, .signingUp(bm, mf, .notSent(_, er)))), .dismissFocus):
      state.flow = .signUp(.questions(n, e, p, .signingUp(bm, mf, .notSent(nil, er))))
      return .none
    case let (.signUp(.questions(n, e, p, .signingUp(_, mf, .notSent(f, er)))), .businessManagesChanged(newBM)):
      if let newBM = newBM {
        state.flow = .signUp(.questions(n, e, p, .signingUp(newBM, mf, .notSent(f, er))))
      } else {
        state.flow = .signUp(.questions(n, e, p, .answering(.right(mf), .left(.businessManages))))
      }
      return .none
    case let (.signUp(.questions(n, e, p, .signingUp(bm, _, .notSent(f, er)))), .managesForChanged(newMF)):
      if let newMF = newMF {
        state.flow = .signUp(.questions(n, e, p, .signingUp(bm, newMF, .notSent(f, er))))
      } else {
        state.flow = .signUp(.questions(n, e, p, .answering(.left(bm), .left(.managesFor))))
      }
      return .none
    case let (.signUp(.questions(n, e, p, .signingUp(bm, mf, .notSent))), .signUp):
      state.flow = .signUp(.questions(n, e, p, .signingUp(bm, mf, .inFlight)))
      return environment.api
        .signUp(n, e, p, bm, mf)
        .receive(on: environment.mainQueue)
        .eraseToEffect()
        .map(AppAction.signedUp)
        .cancellable(id: SignUpID(), cancelInFlight: true)
    case let (.signUp(.questions(n, e, p, .signingUp(bm, mf, .inFlight))), .signedUp(.success)):
      state.flow = .signUp(.verification(.entering(nil, .focused, nil), e, p))
      return .merge(
        Effect.timer(  // Impossible without a timer because of an iOS bug: https://twitter.com/steipete/status/787985965432369152
          id: VerificationPasteboardSubscriptionID(),
          every: 5,
          on: environment.mainQueue
        )
        .receive(on: environment.mainQueue)
        .flatMap(constant(checkVerificationCode))
        .eraseToEffect()
      )
    case let (.signUp(.questions(n, e, p, .signingUp(bm, mf, .inFlight))), .signedUp(.failure(failure))):
      state.flow = .signUp(.questions(n, e, p, .signingUp(bm, mf, .notSent(nil, failure *^? /APIError<CognitoError>.error))))
      return .none
    case let (.signUp(.questions(n, e, p, .answering(ebmmf, _))), .businessManagesSelected):
      state.flow = .signUp(.questions(n, e, p, .answering(ebmmf, .left(.businessManages))))
      return .none
    case let (.signUp(.questions(n, e, p, .answering(ebmmf, _))), .managesForSelected):
      state.flow = .signUp(.questions(n, e, p, .answering(ebmmf, .left(.managesFor))))
      return .none
    case let (.signUp(.questions(n, e, p, .answering(ebmmf, .left))), .dismissFocus),
         let (.signUp(.questions(n, e, p, .answering(ebmmf, .none))), .dismissFocus):
      state.flow = .signUp(.questions(n, e, p, .answering(ebmmf, nil)))
      return .none
    case let (.signUp(.questions(n, e, p, .answering(ebmmf, _))), .businessManagesChanged(newBM)):
      switch (ebmmf, newBM) {
      case let (.none, .some(newBM)),
           let (.left, .some(newBM)):
        state.flow = .signUp(.questions(n, e, p, .answering(.left(newBM), .left(.businessManages))))
      case let (.right(mf), .some(newBM)):
        state.flow = .signUp(.questions(n, e, p, .signingUp(newBM, mf, .notSent(.businessManages, nil))))
      case (.left, .none):
        state.flow = .signUp(.questions(n, e, p, .answering(nil, .left(.businessManages))))
      case (.some(.right), .none),
           (.none, .none):
        break
      }
      return .none
    case let (.signUp(.questions(n, e, p, .answering(ebmmf, _))), .managesForChanged(newMF)):
      switch (ebmmf, newMF) {
      case let (.none, .some(newMF)),
           let (.right, .some(newMF)):
        state.flow = .signUp(.questions(n, e, p, .answering(.right(newMF), .left(.managesFor))))
      case let (.left(bm), .some(newMF)):
        state.flow = .signUp(.questions(n, e, p, .signingUp(bm, newMF, .notSent(.managesFor, nil))))
      case (.right, .none):
        state.flow = .signUp(.questions(n, e, p, .answering(nil, .left(.managesFor))))
      case (.some(.left), .none),
           (.none, .none):
        break
      }
      return .none
    
    case (.signUp(.verification), .willEnterForeground):
      return checkVerificationCode
    case let (.signUp(.verification(.entering, e, p)), .verificationExtractedFromPasteboard(c)),
         let (.signUp(.verification(.entered(_, .notSent), e, p)), .verificationExtractedFromPasteboard(c)):
      state.flow = .signUp(.verification(.entered(c, .inFlight), e, p))
      return verify(email: e, password: p, code: c)
    case let (.signUp(.verification(_, e, p)), .autoSignInFailed(failure)):
      state.flow = .signUp(.verification(.entering(nil, .unfocused, failure *^? /APIError<CognitoError>.error), e, p))
      return .none
    case let (.signUp(.verification(.entered(c, .notSent(.unfocused, error)), e, p)), .focusVerification):
      state.flow = .signUp(.verification(.entered(c, .notSent(.focused, error)), e, p))
      return .none
    case let (.signUp(.verification(.entering(c, .unfocused, er), e, p)), .focusVerification):
      state.flow = .signUp(.verification(.entering(c, .focused, er), e, p))
      return .none
    case let (.signUp(.verification(.entered(c, .notSent(.focused, error)), e, p)), .dismissFocus):
      state.flow = .signUp(.verification(.entered(c, .notSent(.unfocused, error)), e, p))
      return .none
    case let (.signUp(.verification(.entering(c, .focused, er), e, p)), .dismissFocus):
      state.flow = .signUp(.verification(.entering(c, .unfocused, er), e, p))
      return .none
    case let (.signUp(.verification(.entering(nil, f, er), e, p)), .firstVerificationFieldChanged(s)):
      if let verification = VerificationCode(string: s) {
        return Effect(value: AppAction.verificationExtractedFromPasteboard(verification))
      } else {
        if let digit = VerificationCode.Digit(string: s) {
          state.flow = .signUp(.verification(.entering(.one(digit), f, er), e, p))
        }
        return .none
      }
    case let (.signUp(.verification(.entering(.one(d), f, er), e, p)), .secondVerificationFieldChanged(s)):
      if let digit = VerificationCode.Digit(string: s) {
        state.flow = .signUp(.verification(.entering(.two(d, digit), f, er), e, p))
      }
      return .none
    case let (.signUp(.verification(.entering(.two(d1, d2), f, er), e, p)), .thirdVerificationFieldChanged(s)):
      if let digit = VerificationCode.Digit(string: s) {
        state.flow = .signUp(.verification(.entering(.three(d1, d2, digit), f, er), e, p))
      }
      return .none
    case let (.signUp(.verification(.entering(.three(d1, d2, d3), f, er), e, p)), .fourthVerificationFieldChanged(s)):
      if let digit = VerificationCode.Digit(string: s) {
        state.flow = .signUp(.verification(.entering(.four(d1, d2, d3, digit), f, er), e, p))
      }
      return .none
    case let (.signUp(.verification(.entering(.four(d1, d2, d3, d4), f, er), e, p)), .fifthVerificationFieldChanged(s)):
      if let digit = VerificationCode.Digit(string: s) {
        state.flow = .signUp(.verification(.entering(.five(d1, d2, d3, d4, digit), f, er), e, p))
      }
      return .none
    case let (.signUp(.verification(.entering(.five(d1, d2, d3, d4, d5), f, er), e, p)), .sixthVerificationFieldChanged(s)):
      if let digit = VerificationCode.Digit(string: s) {
        let verificationCode = VerificationCode(first: d1, second: d2, third: d3, fourth: d4, fifth: d5, sixth: digit)
        state.flow = .signUp(.verification(.entered(verificationCode, .inFlight), e, p))
        return verify(email: e, password: p, code: verificationCode)
      }
      return .none
    case let (.signUp(.verification(stage, e, p)), .deleteVerificationDigit):
      switch stage {
      case let .entered(c, .notSent(_, er)):
        state.flow = .signUp(.verification(.entering(.five(c.first, c.second, c.third, c.fourth, c.fifth), .focused, er), e, p))
      case let .entering(.five(d1, d2, d3, d4, _), _, er):
        state.flow = .signUp(.verification(.entering(.four(d1, d2, d3, d4), .focused, er), e, p))
      case let .entering(.four(d1, d2, d3, _), _, er):
        state.flow = .signUp(.verification(.entering(.three(d1, d2, d3), .focused, er), e, p))
      case let .entering(.three(d1, d2, _), _, er):
        state.flow = .signUp(.verification(.entering(.two(d1, d2), .focused, er), e, p))
      case let .entering(.two(d1, _), _, er):
        state.flow = .signUp(.verification(.entering(.one(d1), .focused, er), e, p))
      case let .entering(.one, _, er):
        state.flow = .signUp(.verification(.entering(nil, .focused, er), e, p))
      default:
        break
      }
      return .none
    case let (.signUp(.verification(.entering, e, p)), .resendVerificationCode),
         let (.signUp(.verification(.entered(_, .notSent), e, p)), .resendVerificationCode):
      return .merge(
        environment.api
          .resendVerificationCode(e)
          .flatMap { (result: Result<ResendVerificationSuccess, APIError<ResendVerificationError>>) -> Effect<AppAction, Never> in
            
            let makeSDKBaked = makeSDK(DriverID(rawValue: e.rawValue))
            
            switch result {
            case .success:
              return .none
            case .failure(.error(.alreadyVerified)):
              return environment.api
                .signIn(e, p)
                .receive(on: environment.mainQueue)
                .eraseToEffect()
                .flatMap { (result: Result<PublishableKey, APIError<CognitoError>>) -> Effect<AppAction, Never> in
                  switch result {
                  case let .success(pk):
                    return makeSDKBaked(pk)
                  case let .failure(error):
                    return Effect(value: AppAction.autoSignInFailed(error))
                  }
                }
                .eraseToEffect()
            case let .failure(.error(.error(error))):
              return Effect(value: AppAction.autoSignInFailed(.error(error)))
            case let .failure(.network(error)):
              return Effect(value: AppAction.autoSignInFailed(.network(error)))
            case let .failure(.unknown(response)):
              return Effect(value: AppAction.autoSignInFailed(.unknown(response)))
            case let .failure(.api(e)):
              return Effect(value: AppAction.autoSignInFailed(.api(e)))
            case let .failure(.server(e)):
              return Effect(value: AppAction.autoSignInFailed(.server(e)))
            }
            
          }
          .eraseToEffect()
          .cancellable(id: ResendVerificationID(), cancelInFlight: true),
        environment.hapticFeedback
          .notifySuccess()
          .fireAndForget()
      )
    default:
      return .none
    }
  },
  // Sign In
  Reducer { state, action, environment in
    
    func makeSDK(_ driverID: DriverID) -> (PublishableKey) -> Effect<AppAction, Never> {
      { publishableKey in
        environment.hyperTrack
          .makeSDK(publishableKey)
          .receive(on: environment.mainQueue)
          .flatMap { (status: SDKStatus, permissions: Permissions) -> Effect<AppAction, Never> in
            switch status {
            case .locked:
              return Effect(value: AppAction.appHandleSDKLocked)
            case let .unlocked(deviceID, unlockedStatus):
              return .merge(
                Effect(value: AppAction.appHandleSDKUnlocked(publishableKey, driverID, deviceID, unlockedStatus, permissions)),
                environment.hyperTrack
                  .subscribeToStatusUpdates()
                  .receive(on: environment.mainQueue)
                  .eraseToEffect()
                  .map(AppAction.statusUpdated),
                environment.hyperTrack
                  .setDriverID(driverID)
                  .receive(on: environment.mainQueue)
                  .eraseToEffect()
                  .fireAndForget()
              )
            }
          }
          .eraseToEffect()
      }
    }
    
    struct SignInID: Hashable {}
    
    switch state.flow {
    
    case let .signIn(.editingCredentials(e, p, f, er)):
      switch action {
      case .goToSignUp:
        return Effect(value: .appHandleSignUpWith(e))
      case let .emailChanged(e):
        state.flow = .signIn(.editingCredentials(e, p, f, er))
        return .none
      case .focusEmail:
        state.flow = .signIn(.editingCredentials(e, p, .email, er))
        return .none
      case .focusPassword:
        state.flow = .signIn(.editingCredentials(e, p, .password, er))
        return .none
      case let .passwordChanged(p):
        state.flow = .signIn(.editingCredentials(e, p, f, er))
        return .none
      case .signIn:
        if let e = e, let p = p {
          state.flow = .signIn(.signingIn(e, p))
          return environment.api
            .signIn(e, p)
            .receive(on: environment.mainQueue)
            .eraseToEffect()
            .map(AppAction.signedIn)
            .cancellable(id: SignInID(), cancelInFlight: true)
        } else {
          return .none
        }
      case .dismissFocus:
        state.flow = .signIn(.editingCredentials(e, p, nil, er))
        return .none
      default:
        return .none
      }
    case let .signIn(.signingIn(e, p)):
      switch action {
      case .cancelSignIn:
        state.flow = .signIn(.editingCredentials(e, p, nil, nil))
        return .cancel(id: SignInID())
      case let .signedIn(.success(pk)):
        return makeSDK(DriverID(rawValue: e.rawValue))(pk)
      case let .signedIn(.failure(failure)):
        state.flow = .signIn(.editingCredentials(e, p, nil, failure *^? /APIError<CognitoError>.error))
        return .none
      default:
        return .none
      }
    default:
      return .none
    }
  },
  // DriverID
  Reducer { state, action, environment in
    switch state.flow {
    case let .driverID(drID, pk):
      switch action {
      case let .driverIDChanged(newDrID):
        state.flow = .driverID(newDrID, pk)
        return .none
      case .setDriverID:
        if let drID = drID {
          return environment.hyperTrack
            .makeSDK(pk)
            .receive(on: environment.mainQueue)
            .eraseToEffect()
            .map(AppAction.madeSDK)
        }
        return .none
      case .madeSDK(.locked, _):
        state.flow = .noMotionServices
        return .none
      case let .madeSDK(.unlocked(deID, us), p):
        if let drID = drID {
          state.flow = .main([], nil, [], nil, .defaultTab, pk, drID, deID, us, p, .none, .dialogSplash(.notShown), .firstRun)
          return .concatenate(
            environment.hyperTrack
              .subscribeToStatusUpdates()
              .receive(on: environment.mainQueue)
              .eraseToEffect()
              .map(AppAction.statusUpdated),
            environment.hyperTrack
              .setDriverID(drID)
              .receive(on: environment.mainQueue)
              .eraseToEffect()
              .fireAndForget()
          )
        } else {
          return .none
        }
      default:
        return .none
      }
    default:
      return .none
    }
  },
  // Orders
  Reducer { state, action, environment in
    switch state.flow {
    case let .main(v, sv, places, h, s, pk, drID, deID, us, p, r, ps, e):
      let getOrders = getOrdersEffect(environment.api.getOrders(pk, deID), environment.mainQueue)
      let getPlaces = getPlacesEffect(environment.api.getPlaces(pk, deID), environment.api.reverseGeocode, environment.mainQueue)
      let getHistory = getHistoryEffect(environment.api.getHistory(pk, deID, environment.date()), environment.mainQueue)
      let fvs = filterOutOldOrders(environment.date())(v)
      let fv = filterOutOldOrder(environment.date())(sv)
      
      
      switch action {
      case .willEnterForeground,
           .receivedPushNotification:
        var effects: [Effect<AppAction, Never>] = []
        if r.history == .notRefreshingHistory {
          effects += [getHistory]
        }
        if r.orders == .notRefreshingOrders {
          effects += [getOrders]
        }
        if r.places == .notRefreshingPlaces {
          effects += [getPlaces]
        }
        state.flow = .main(fvs, fv, places, h, s, pk, drID, deID, us, p, .all, ps, e)
        return .merge(effects)
      case .updateOrders:
        let effect: Effect<AppAction, Never>
        let refreshing: Refreshing
        if r.orders == .notRefreshingOrders {
          effect = getOrders
        } else {
          effect = .none
        }
        state.flow = .main(fvs, fv, places, h, s, pk, drID, deID, us, p, r |> \.orders *< .refreshingOrders, ps, e)
        return effect
      case let .copyToPasteboard(s):
        return .merge(
          environment.hapticFeedback
            .notifySuccess()
            .fireAndForget(),
          environment.pasteboard
          .copyToPasteboard(s)
          .fireAndForget()
        )
      case let .selectOrder(str):
        let (v, sv) = selectOrder(o: v, so: sv, id: str)
        state.flow = .main(v, sv, places, h, .orders, pk, drID, deID, us, p, r, ps, e)
        return .none
      case .cancelOrder:
        if var sv = sv, sv.geotagSent.checkedOut == nil, sv.geotagSent.cancelled == nil {
          sv.geotagSent = .cancelled(sv.geotagSent.isVisited, environment.date())
          state.flow = .main(v, sv, places, h, s, pk, drID, deID, us, p, r, ps, e)
          return .merge(
            environment.hyperTrack
              .addGeotag(.cancel(sv.id, sv.source, sv.orderNote))
              .fireAndForget(),
            environment.hapticFeedback
              .notifySuccess()
              .fireAndForget()
          )
        } else {
          return .none
        }
      case .checkOutOrder:
        guard var sv = sv, sv.geotagSent.checkedOut == nil, sv.geotagSent.cancelled == nil else {
          return .none
        }
        sv.geotagSent = .checkedOut(sv.geotagSent.isVisited, environment.date())
        state.flow = .main(v, sv, places, h, s, pk, drID, deID, us, p, r, ps, e)
        return .merge(
          environment.hyperTrack
            .addGeotag(.checkOut(sv.id, sv.source, sv.orderNote))
            .fireAndForget(),
          environment.hapticFeedback
            .notifySuccess()
            .fireAndForget()
        )
      case let .orderNoteChanged(n):
        guard var sv = sv else { return .none }
        
        sv.orderNote = n >>- Order.OrderNote.init(rawValue:)
        
        state.flow = .main(v, sv, places, h, s, pk, drID, deID, us, p, r, ps, e)
        return .none
      case .deselectOrder:
        state.flow = .main(sv.map { Set.insert($0)(v) } ?? v, nil, places, h, s, pk, drID, deID, us, p, r, ps, e)
        return .none
      case .focusOrderNote:
        guard var sv = sv else { return .none }
        
        sv.noteFieldFocused = true
        
        state.flow = .main(v, sv, places, h, s, pk, drID, deID, us, p, r, ps, e)
        return .none
      case .openAppleMaps:
        guard var sv = sv else { return .none }
        
        let add: Either<FullAddress, Street>?
        switch (sv.address.fullAddress, sv.address.street) {
        case (.none, .none):
          add = .none
        case let (.some(f), _):
          add = .left(f)
        case let (_, .some(s)):
          add = .right(s)
        }
        
        return environment.maps
          .openMap(sv.location, add)
          .fireAndForget()
      case .pickUpOrder:
        guard var sv = sv, sv.geotagSent == .notSent else { return .none }
        
        sv.geotagSent = .pickedUp
        
        state.flow = .main(v, sv, places, h, s, pk, drID, deID, us, p, r, ps, e)
        
        return .merge(
          environment.hyperTrack
            .addGeotag(.pickUp(sv.id, sv.source))
            .fireAndForget(),
          environment.hapticFeedback
            .notifySuccess()
            .fireAndForget()
        )
      case .dismissFocus:
        guard var sv = sv else { return .none }
        
        sv.noteFieldFocused = false
        
        state.flow = .main(v, sv, places, h, s, pk, drID, deID, us, p, r, ps, e)
        return .none
      case .openSettings:
        return environment.hyperTrack
          .openSettings()
          .fireAndForget()
      case .requestLocationPermissions:
        return environment.hyperTrack
          .requestLocationPermissions()
          .fireAndForget()
      case .requestMotionPermissions:
        return environment.hyperTrack
          .requestMotionPermissions()
          .receive(on: environment.mainQueue)
          .eraseToEffect()
          .map(AppAction.statusUpdated)
      case .requestPushAuthorization:
        state.flow = .main(v, sv, places, h, s, pk, drID, deID, us, p, r, .dialogSplash(.waitingForUserAction), e)
        return environment.push
          .requestAuthorization()
          .receive(on: environment.mainQueue)
          .map(constant(AppAction.userHandledPushAuthorization))
          .eraseToEffect()
      case .userHandledPushAuthorization:
        state.flow = .main(v, sv, places, h, s, pk, drID, deID, us, p, r, .dialogSplash(.shown), e)
        return .none
      case let .statusUpdated(st, p):
        switch st {
        case .locked:
          state.flow = .noMotionServices
        case let .unlocked(deID, us):
          state.flow = .main(v, sv, places, h, s, pk, drID, deID, us, p, r, ps, e)
        }
        return .none
      case .startTracking:
        var effects: [Effect<AppAction, Never>] = [
          environment.hyperTrack
            .startTracking()
            .fireAndForget(),
          environment.hyperTrack
            .addGeotag(.clockIn)
            .fireAndForget()
        ]
        if r.history == .notRefreshingHistory {
          effects += [getHistory]
        }
        if r.orders == .notRefreshingOrders {
          effects += [getOrders]
        }
        state.flow = .main(fvs, fv, places, h, s, pk, drID, deID, us, p, .all, ps, e)
        return .merge(effects)
      case .stopTracking:
        var effects: [Effect<AppAction, Never>] = [
          environment.hyperTrack
            .stopTracking()
            .fireAndForget(),
          environment.hyperTrack
            .addGeotag(.clockOut)
            .fireAndForget()
        ]
        if r.history == .refreshingHistory {
          effects += [.cancel(id: RefreshingHistoryID())]
        }
        if r.orders == .refreshingOrders {
          effects += [.cancel(id: RefreshingOrdersID())]
        }
        if r.places == .refreshingPlaces {
          effects += [.cancel(id: RefreshingPlacesID())]
        }
        state.flow = .main(v, sv, places, h, s, pk, drID, deID, us, p, .none, ps, e)
        return .merge(effects)
      case let .reverseGeocoded(g):
        state.flow = .main(updateAddress(for: v, with: g), sv <¡> updateAddress(with: g), places, h, s, pk, drID, deID, us, p, r, ps, e)
        return .none
      case let .ordersUpdated(.success(vs)):
        if vs.isEmpty {
          state.flow = .main(v, sv, places, h, s, pk, drID, deID, us, p, r |> \.orders *< .notRefreshingOrders, ps, e)
          return .none
        } else {
          let allVs = sv.map { Set.insert($0)(v) } ?? v
          let updatedVs = vs |> update(allVs)
          let freshVs = updatedVs |> filterOutOldOrders(environment.date())
          
          let (nv, nsv): (Set<Order>, Order?)
          if let id = sv?.id.string {
            (nv, nsv) = selectOrder(o: freshVs, so: nil, id: id)
          } else {
            (nv, nsv) = (freshVs, nil)
          }
          
          state.flow = .main(nv, nsv, places, h, s, pk, drID, deID, us, p, r |> \.orders *< .notRefreshingOrders, ps, e)
          if let reverseGeocodingCoordinates = NonEmptySet(rawValue: orderCoordinatesWithoutAddress(freshVs)) {
            return reverseGeocodingCoordinates.publisher
              .flatMap { coordinate in
                
                return environment.api.reverseGeocode(coordinate)
                  .map { GeocodedResult(coordinate: coordinate, address: $0) }
              }
              .collect()
              .receive(on: environment.mainQueue)
              .eraseToEffect()
              .map(AppAction.reverseGeocoded)
          } else {
            return .none
          }
        }
      case .ordersUpdated(.failure):
        state.flow = .main(v, sv, places, h, s, pk, drID, deID, us, p, r |> \.orders *< .notRefreshingOrders, ps, e)
        return .none
      case let .historyUpdated(newH):
        state.flow = .main(v, sv, places, resultSuccess(newH) ?? h, s, pk, drID, deID, us, p, r |> \.history *< .notRefreshingHistory, ps, e)
        return .none
      default:
        return .none
      }
    default:
      return .none
    }
  },
  // Places
  Reducer { state, action, environment in
    switch (state.flow, action) {
    case let (.main(v, sv, places, h, s, pk, drID, deID, us, p, r, ps, e), .placesUpdated(newPlaces)):
      state.flow = .main(v, sv, resultSuccess(newPlaces) ?? places, h, s, pk, drID, deID, us, p, r |> \.places *< .notRefreshingPlaces, ps, e)
      return .none
    case let (.main(v, sv, places, h, s, pk, drID, deID, us, p, r, ps, e), .updatePlaces):
      if r.places == .refreshingPlaces {
        return .none
      }
      state.flow = .main(v, sv, places, h, s, pk, drID, deID, us, p, r |> \.places *< .refreshingPlaces, ps, e)
      return getPlacesEffect(environment.api.getPlaces(pk, deID), environment.api.reverseGeocode, environment.mainQueue)
    default:
      return .none
    }
  },
  // TabView
  Reducer { state, action, environment in
    switch (state.flow, action) {
    case let (.main(v, sv, places, h, s, pk, drID, deID, us, p, r, ps, e), .switchToOrders) where s != .orders:
      state.flow = .main(v, sv, places, h, .orders, pk, drID, deID, us, p, r, ps, e)
      return Effect(value: .updateOrders)
    case let (.main(v, sv, places, h, s, pk, drID, deID, us, p, r, ps, e), .switchToPlaces) where s != .places:
      if r.places == .notRefreshingPlaces {
        state.flow = .main(v, sv, places, h, .places, pk, drID, deID, us, p, r |> \.places *< .refreshingPlaces, ps, e)
        return getPlacesEffect(environment.api.getPlaces(pk, deID), environment.api.reverseGeocode, environment.mainQueue)
      } else {
        state.flow = .main(v, sv, places, h, .places, pk, drID, deID, us, p, r, ps, e)
        return .none
      }
    case let (.main(v, sv, places, h, s, pk, drID, deID, us, p, r, ps, e), .switchToMap) where s != .map:
      state.flow = .main(v, sv, places, h, .map, pk, drID, deID, us, p, r, ps, e)
      
      let effect: Effect<AppAction, Never>
      if r.history == .notRefreshingHistory {
        effect = getHistoryEffect(environment.api.getHistory(pk, deID, environment.date()), environment.mainQueue)
      } else {
        effect = .none
      }
      state.flow = .main(v, sv, places, h, .map, pk, drID, deID, us, p, r |> \.history *< .refreshingHistory, ps, e)
      return effect
    case let (.main(v, sv, places, h, s, pk, drID, deID, us, p, r, ps, e), .switchToSummary) where s != .summary:
      state.flow = .main(v, sv, places, h, .summary, pk, drID, deID, us, p, r, ps, e)
      return .none
    case let (.main(v, sv, places, h, s, pk, drID, deID, us, p, r, ps, e), .switchToProfile) where s != .profile:
      state.flow = .main(v, sv, places, h, .profile, pk, drID, deID, us, p, r, ps, e)
      return .none
    default:
      return .none
    }
  }
)
.autosave()
.refreshVisitsAndHistoryOnVisitsTransition()
.startTrackingOnFirstRunExperience()

extension Reducer where State == AppState, Action == AppAction, Environment == SystemEnvironment<AppEnvironment> {
  func refreshVisitsAndHistoryOnVisitsTransition() -> Reducer {
    .init { state, action, environment in
      let previousState = state
      let effects = self.run(&state, action, environment)
      let nextState = state
      
      switch (previousState.flow, nextState.flow) {
      case (.main, .main): return effects
      case let (_, .main(v, sv, places, h, s, pk, drID, deID, us, p, r, ps, e)):
        let getOrders = getOrdersEffect(environment.api.getOrders(pk, deID), environment.mainQueue)
        let getPlaces = getPlacesEffect(environment.api.getPlaces(pk, deID), environment.api.reverseGeocode, environment.mainQueue)
        let getHistory = getHistoryEffect(environment.api.getHistory(pk, deID, environment.date()), environment.mainQueue)
        
        var effects: [Effect<AppAction, Never>] = [effects]
        if r.history == .notRefreshingHistory {
          effects += [getHistory]
        }
        if r.orders == .notRefreshingOrders {
          effects += [getOrders]
        }
        if r.places == .notRefreshingPlaces {
          effects += [getPlaces]
        }
        
        state.flow = .main(v, sv, places, h, s, pk, drID, deID, us, p, .all, ps, e)
        return .merge(effects)
      default: return effects
      }
    }
  }
}

extension Reducer where State == AppState, Action == AppAction, Environment == SystemEnvironment<AppEnvironment> {
  func startTrackingOnFirstRunExperience() -> Reducer {
    .init { state, action, environment in
      let effects = self.run(&state, action, environment)
      
      switch state.flow {
      case let .main(v, sv, places, h, s, pk, drID, deID, .stopped, p, .none, .dialogSplash(.shown), .firstRun)
            where p.locationAccuracy == .full
            && p.locationPermissions == .authorized
            && p.motionPermissions == .authorized:
        
        let getOrders = getOrdersEffect(environment.api.getOrders(pk, deID), environment.mainQueue)
        let getPlaces = getPlacesEffect(environment.api.getPlaces(pk, deID), environment.api.reverseGeocode, environment.mainQueue)
        let getHistory = getHistoryEffect(environment.api.getHistory(pk, deID, environment.date()), environment.mainQueue)
        let combinedEffects: [Effect<AppAction, Never>] = [
          effects,
          environment.hyperTrack
            .startTracking()
            .fireAndForget(),
          getOrders,
          getPlaces,
          getHistory
        ]
        state.flow = .main(v, sv, places, h, s, pk, drID, deID, .running, p, .all, .dialogSplash(.shown), .regular)
        return .merge(combinedEffects)
      default: return effects
      }
    }
  }
}

public func resultSuccess<Success, Failure>(_ r: Result<Success, Failure>) -> Success? {
  try? r.get()
}

func selectOrder(o: Set<Order>, so: Order?, id: String) -> (Set<Order>, Order?) {
  let v = combine(o, so)
  let sv: Order? = v.firstIndex(where: { $0.id.string == id }).map { v[$0] }
  return (v.filter { $0.id.string != id }, sv)
}

func update(_ vs: Set<Order>) -> ([APIOrderID: APIOrder]) -> Set<Order> {
  { apiOrders in
    Set(
      apiOrders.map { tuple in
        if let match = vs.first(where: { tuple.key.rawValue == $0.id.rawValue }) {
          return update(order: match, with: (tuple.key, tuple.value))
        } else {
          return Order(apiOrder: (tuple.key, tuple.value))
        }
      }
      +
      vs.compactMap { v in
        if apiOrders[rewrap(v.id)] == nil {
          return v
        } else {
          return nil
        }
      }
    )
  }
}

func combine(_ v: Set<Order>, _ sv: Order?) -> Set<Order> {
  sv.map { Set.insert($0)(v) } ?? v
}


func update(order: Order?, with apiOrder: (id: APIOrderID, order: APIOrder) ) -> Order {
  guard var order = order else { return .init(apiOrder: apiOrder) }

  order.geotagSent.isVisited = apiOrder.order.visitStatus.map(Order.Geotag.Visited.init(visitStatus:))
  
  return order
}

extension Order.Geotag.Visited {
  init(visitStatus: VisitStatus) {
    switch visitStatus {
    case let .entered(entry): self = .entered(entry)
    case let .visited(entry, exit): self = .visited(entry, exit)
    }
  }
}

extension Order {
  init(apiOrder: (id: APIOrderID, order: APIOrder)) {
    let source: Order.Source
    switch apiOrder.order.source {
    case .order: source = .order
    case .trip: source = .trip
    }
    
    self.init(
      id: rewrap(apiOrder.id),
      createdAt: apiOrder.order.createdAt,
      source: source,
      location: apiOrder.order.centroid,
      geotagSent: .notSent,
      noteFieldFocused: false,
      address: .none,
      orderNote: nil,
      metadata: rewrapDictionary(apiOrder.order.metadata)
    )
  }
}

func rewrapDictionary<A, B, C, D, E, F>(_ dict: Dictionary<Tagged<A, B>, Tagged<C, D>>) -> Dictionary<Tagged<E, B>, Tagged<F, D>> {
  Dictionary(uniqueKeysWithValues: dict.map { (rewrap($0), rewrap($1)) })
}

func rewrap<Source, Value, Destination>(_ source: Tagged<Source, Value>) -> Tagged<Destination, Value> {
  .init(rawValue: source.rawValue)
}

func orderCoordinatesWithoutAddress(_ orders: Set<Order>) -> Set<Coordinate> {
  Set(orders.compactMap { $0.address == .none ? $0.location : nil })
}

func updateAddress(for orders: Set<Order>, with geocodedResults: [GeocodedResult]) -> Set<Order> {
  Set(orders.map(updateAddress(with: geocodedResults)))
}

func updateAddress(with geocodedResults: [GeocodedResult]) -> (Order) -> Order {
  {
    var v = $0
    for g in geocodedResults where v.location == g.coordinate {
      v.address = g.address
    }
    return v
  }
}

extension Set {
  static func insert(_ newMember: Element) -> (Self) -> Self {
    { set in
      var set = set
      set.insert(newMember)
      return set
    }
  }
}
