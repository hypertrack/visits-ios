import APIEnvironment
import AppArchitecture
import Combine
import ComposableArchitecture
import DeepLinkEnvironment
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
  
  public static let initialState = AppState(network: .offline, flow: .created)
}

public enum AppFlow: Equatable {
  case created
  case appLaunching
  case noMotionServices
  case signUp(SignUpState)
  case signIn(SignInState)
  case driverID(DriverID?, PublishableKey, ProcessingDeepLink?)
  case visits(Set<Visit>, Visit?, History?, TabSelection, PublishableKey, DriverID, DeviceID, SDKUnlockedStatus, Permissions, These<RefreshingVisits, RefreshingHistory>?, PushStatus, Experience, ProcessingDeepLink?)
}

public struct RefreshingVisits: Equatable {}
public struct RefreshingHistory: Equatable {}

public enum SignInState: Equatable {
  case signingIn(Email, Password)
  case editingCredentials(These<Email, Password>?, Either<These<SignInFocus, SignInError>, ProcessingDeepLink>?)
}

public enum SignInFocus: Equatable { case email, password }

public typealias SignInError = Tagged<SignInErrorTag, NonEmptyString>
public enum SignInErrorTag {}


public struct GeocodedResult: Equatable {
  let coordinate: Coordinate
  let address: These<Visit.Street, Visit.FullAddress>?
}

// MARK: - Action

public enum AppAction: Equatable {
  // App
  case appHandleSDKLocked
  case appHandleSDKUnlocked(PublishableKey, DriverID, DeviceID, SDKUnlockedStatus, Permissions, PushStatus, Experience)
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
  case signedUp(Result<SignUpError?, APIError>)
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
  case autoSignInFailed(SignUpError)
  // Sign In
  case goToSignUp
  case cancelSignIn
  case emailChanged(Email?)
  case focusEmail
  case focusPassword
  case passwordChanged(Password?)
  case signIn
  case signedIn(Result<PublishableKey, APIError>)
  // DriverID
  case driverIDChanged(DriverID?)
  case setDriverID
  // Visits
  case selectVisit(String)
  case updateVisits
  // Visit
  case cancelVisit
  case checkOutVisit
  case visitNoteChanged(NonEmptyString?)
  case deselectVisit
  case focusVisitNote
  case openAppleMaps
  case pickUpVisit
  case reverseGeocoded([GeocodedResult])
  case visitsUpdated(Result<[APIVisitID: APIVisit], APIError>)
  // TabView
  case switchToVisits
  case switchToMap
  case switchToSummary
  case switchToProfile
  // History
  case historyUpdated(Result<History, APIError>)
  // Generic UI
  case dismissFocus
  // Deeplink
  case deepLinkOpened(NSUserActivity)
  case deepLinkTimerFired
  case receivedDeepLink(PublishableKey, DriverID?)
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
}

// MARK: - Environment

public struct AppEnvironment {
  public var api: APIEnvironment
  public var deepLink: DeepLinkEnvironment
  public var hapticFeedback: HapticFeedbackEnvironment
  public var hyperTrack: HyperTrackEnvironment
  public var maps: MapEnvironment
  public var network: NetworkEnvironment
  public var pasteboard: PasteboardEnvironment
  public var push: PushEnvironment
  public var stateRestoration: StateRestorationEnvironment
  
  public init(
    api: APIEnvironment,
    deepLink: DeepLinkEnvironment,
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

struct RefreshingVisitsID: Hashable {}
struct RefreshingHistoryID: Hashable {}

let getVisitsEffect = { (
  getVisits: Effect<Result<[APIVisitID: APIVisit], APIError>, Never>,
  mainQueue: AnySchedulerOf<DispatchQueue>
) in
  getVisits
    .receive(on: mainQueue)
    .eraseToEffect()
    .cancellable(id: RefreshingVisitsID())
    .map(AppAction.visitsUpdated)
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

func over4<A, B, C, D, E, F, Z>(_ f: @escaping (D) -> Z) -> ((A, B, C, D, E, F)) -> (A, B, C, Z, E, F) {
  { ($0.0, $0.1, $0.2, f($0.3), $0.4, $0.5) }
}

func over1<A, B, C, D, E, F, Z>(_ f: @escaping (A) -> Z) -> ((A, B, C, D, E, F)) -> (Z, B, C, D, E, F) {
  { (f($0.0), $0.1, $0.2, $0.3, $0.4, $0.5) }
}

public let appReducer: Reducer<AppState, AppAction, SystemEnvironment<AppEnvironment>> = Reducer.combine(
  networkReducer.pullback(state: \.network, action: .self, environment: constant(())),
  deepLinkReducer,
  stateRestorationReducer,
  Reducer { state, action, environment in
    switch action {
    case .appHandleSDKLocked:
      state.flow = .noMotionServices
      return .none
    case let .appHandleSDKUnlocked(publishableKey, driverID, deviceID, unlockedStatus, permissions, pushStatus, experience):
      state.flow = .visits([], nil, nil, .defaultTab, publishableKey, driverID, deviceID, unlockedStatus, permissions, nil, pushStatus, experience, nil)
      return .none
    default:
      return .none
    }
  },
  // Transitions
  Reducer { state, action, environment in
    switch (state.flow, action) {
    case let (.signIn(.editingCredentials(emailAndPassword, .none)), .goToSignUp):
      state.flow = .signUp(.formFilling(nil, emailAndPassword >>- theseLeft, nil, .name, nil, nil))
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
          .receive(on: environment.mainQueue())
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
                Effect(value: AppAction.appHandleSDKUnlocked(publishableKey, driverID, deviceID, unlockedStatus, permissions, .dialogSplash(.notShown), .firstRun)),
                environment.hyperTrack
                  .subscribeToStatusUpdates()
                  .receive(on: environment.mainQueue())
                  .eraseToEffect()
                  .map(AppAction.statusUpdated),
                environment.hyperTrack
                  .setDriverID(driverID)
                  .receive(on: environment.mainQueue())
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
      .receive(on: environment.mainQueue())
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
        .receive(on: environment.mainQueue())
        .flatMap { (result: Result<VerificationResponse, APIError>) -> Effect<AppAction, Never> in
                    
          let makeSDKBaked = makeSDK(DriverID(rawValue: email.rawValue))
          
          switch result {
          case let .success(.success(pk)):
            return makeSDKBaked(pk)
          case .success(.alreadyVerified):
            return environment.api
              .signIn(email, password)
              .receive(on: environment.mainQueue())
              .eraseToEffect()
              .flatMap { (result: Result<PublishableKey, APIError>) -> Effect<AppAction, Never> in
                switch result {
                case let .success(pk):
                  return makeSDKBaked(pk)
                case let .failure(error):
                  return Effect(value: AppAction.autoSignInFailed(SignUpError(rawValue: "Unknown error")))
                }
              }
              .eraseToEffect()
          case let .success(.error(error)):
            return Effect(value: AppAction.autoSignInFailed(error))
          case let .failure(error):
            return Effect(value: AppAction.autoSignInFailed(SignUpError(rawValue: "Unknown error")))
          }
        }
        .eraseToEffect()
        .cancellable(id: VerifyID(), cancelInFlight: true)
    }
    
    
    switch (state.flow, action) {
    
    case let (.signUp(.formFilled(_, _, _, f, _, .none)), .focusBusinessName):
      state.flow = (state.flow |> (/AppFlow.signUp ** /SignUpState.formFilled) *~? over4(constant(.name))) ?? state.flow
      return .none
    case let (.signUp(.formFilled(_, _, _, f, _, .none)), .focusEmail) where f != .email:
      state.flow = (state.flow |> (/AppFlow.signUp ** /SignUpState.formFilled) *~? over4(constant(.email))) ?? state.flow
      return .none
    case let (.signUp(.formFilled(_, _, _, f, _, .none)), .focusPassword) where f != .password:
      state.flow = (state.flow |> (/AppFlow.signUp ** /SignUpState.formFilled) *~? over4(constant(.password))) ?? state.flow
      return .none
    case (.signUp(.formFilled), .dismissFocus):
      state.flow = (state.flow |> (/AppFlow.signUp ** /SignUpState.formFilled) *~? over4(constant(nil))) ?? state.flow
      return .none
    case let (.signUp(.formFilled(n, e, p, f, er, _)), .businessNameChanged(newName)):
      if let newName = newName {
        state.flow = (state.flow |> (/AppFlow.signUp ** /SignUpState.formFilled) *~? over1(constant(newName))) ?? state.flow
      } else {
        state.flow = .signUp(.formFilling(nil, e, p, f, er, nil))
      }
      return .none
    case let (.signUp(.formFilled(n, e, p, f, er, .none)), .emailChanged(newEmail)):
      let newEmail = newEmail.flatMap { $0.cleanup() }
      if let newEmail = newEmail, newEmail.isValid() {
        state.flow = .signUp(.formFilled(n, newEmail, p, f, er, .none))
      } else {
        state.flow = .signUp(.formFilling(n, newEmail, p, f, er, .none))
      }
      return .none
    case let (.signUp(.formFilled(n, e, p, f, er, .none)), .passwordChanged(newPassword)):
      if let newPassword = newPassword, newPassword.isValid() {
        state.flow = .signUp(.formFilled(n, e, newPassword, f, er, .none))
      } else {
        state.flow = .signUp(.formFilling(n, e, newPassword, f, er, .none))
      }
      return .none
    case let (.signUp(.formFilling(n, e, p, f, er, .none)), .completeSignUpForm):
      switch (n, e, p) {
      case (.none, _, _):
        state.flow = .signUp(.formFilling(n, e, p, f, "Business name required", .none))
      case (_, .none, _):
        state.flow = .signUp(.formFilling(n, e, p, f, "Please enter a valid email ID", .none))
      case let (_, .some(e), _) where !e.isValid():
        state.flow = .signUp(.formFilling(n, e, p, f, "Please enter a valid email ID", .none))
      case (_, _, .none):
        state.flow = .signUp(.formFilling(n, e, p, f, "Password should be 8 characters or more", .none))
      case let (_, _, .some(p)) where !p.isValid():
        state.flow = .signUp(.formFilling(n, e, p, f, "Password should be 8 characters or more", .none))
      case let (.some(n), .some(e), .some(p)):
        state.flow = .signUp(.questions(n, e, p, .answering(nil, .left(.businessManages), nil)))
      }
      return .none
    case let (.signUp(.formFilled(n, e, p, _, _, _)), .completeSignUpForm):
      state.flow = .signUp(.questions(n, e, p, .answering(nil, .left(.businessManages), nil)))
      return .none
    case let (.signUp(.formFilled(_, e, _, _, _, _)), .goToSignIn):
      state.flow = .signIn(.editingCredentials(e <¡> These.this, nil))
      return .none
      
    case let (.signUp(.formFilling(_, _, _, f, _, .none)), .focusBusinessName):
      state.flow = (state.flow |> (/AppFlow.signUp ** /SignUpState.formFilling) *~? over4(constant(.name))) ?? state.flow
      return .none
    case let (.signUp(.formFilling(_, _, _, f, _, .none)), .focusEmail) where f != .email:
      state.flow = (state.flow |> (/AppFlow.signUp ** /SignUpState.formFilling) *~? over4(constant(.email))) ?? state.flow
      return .none
    case let (.signUp(.formFilling(_, _, _, f, _, .none)), .focusPassword) where f != .password:
      state.flow = (state.flow |> (/AppFlow.signUp ** /SignUpState.formFilling) *~? over4(constant(.password))) ?? state.flow
      return .none
    case (.signUp(.formFilling), .dismissFocus):
      state.flow = (state.flow |> (/AppFlow.signUp ** /SignUpState.formFilling) *~? over4(constant(nil))) ?? state.flow
      return .none
    case let (.signUp(.formFilling(n, e, p, f, er, .none)), .businessNameChanged(newName)):
      if let newName = newName, let p = p, let e = e, e.isValid(), p.isValid() {
        state.flow = .signUp(.formFilled(newName, e, p, f, er, .none))
      } else {
        state.flow = .signUp(.formFilling(newName, e, p, f, er, .none))
      }
      return .none
    case let (.signUp(.formFilling(n, e, p, f, er, .none)), .emailChanged(newEmail)):
      let newEmail = newEmail.flatMap { $0.cleanup() }
      if let newEmail = newEmail, let p = p, let n = n, newEmail.isValid(), p.isValid() {
        state.flow = .signUp(.formFilled(n, newEmail, p, f, er, .none))
      } else {
        state.flow = .signUp(.formFilling(n, newEmail, p, f, er, .none))
      }
      return .none
    case let (.signUp(.formFilling(n, e, p, f, er, .none)), .passwordChanged(newPassword)):
      if let newPassword = newPassword, let e = e, let n = n, e.isValid(), newPassword.isValid() {
        state.flow = .signUp(.formFilled(n, e, newPassword, f, er, .none))
      } else {
        state.flow = .signUp(.formFilling(n, e, newPassword, f, er, .none))
      }
      return .none
    case let (.signUp(.formFilling(_, e, _, _, _, _)), .goToSignIn):
      state.flow = .signIn(.editingCredentials(e <¡> These.this, nil))
      return .none
    
    case let (.signUp(.questions(n, e, p, _)), .goToSignUp):
      state.flow = .signUp(.formFilled(n, e, p, .none, .none, .none))
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
        state.flow = .signUp(.questions(n, e, p, .answering(.right(mf), .left(.businessManages), nil)))
      }
      return .none
    case let (.signUp(.questions(n, e, p, .signingUp(bm, _, .notSent(f, er)))), .managesForChanged(newMF)):
      if let newMF = newMF {
        state.flow = .signUp(.questions(n, e, p, .signingUp(bm, newMF, .notSent(f, er))))
      } else {
        state.flow = .signUp(.questions(n, e, p, .answering(.left(bm), .left(.managesFor), nil)))
      }
      return .none
    case let (.signUp(.questions(n, e, p, .signingUp(bm, mf, .notSent))), .signUp):
      state.flow = .signUp(.questions(n, e, p, .signingUp(bm, mf, .inFlight)))
      return environment.api
        .signUp(n, e, p, bm, mf)
        .receive(on: environment.mainQueue())
        .eraseToEffect()
        .map(AppAction.signedUp)
        .cancellable(id: SignUpID(), cancelInFlight: true)
    case let (.signUp(.questions(n, e, p, .signingUp(bm, mf, .inFlight))), .signedUp(.success(.none))):
      state.flow = .signUp(.verification(.entering(nil, .focused, nil, nil), e, p))
      return .merge(
        Effect.timer(  // Impossible without a timer because of an iOS bug: https://twitter.com/steipete/status/787985965432369152
          id: VerificationPasteboardSubscriptionID(),
          every: 5,
          on: environment.mainQueue()
        )
        .receive(on: environment.mainQueue())
        .flatMap(constant(checkVerificationCode))
        .eraseToEffect()
      )
    case let (.signUp(.questions(n, e, p, .signingUp(bm, mf, .inFlight))), .signedUp(.success(.some(err)))):
      state.flow = .signUp(.questions(n, e, p, .signingUp(bm, mf, .notSent(nil, err))))
      return .none
    case let (.signUp(.questions(n, e, p, .signingUp(bm, mf, .inFlight))), .signedUp(.failure)):
      state.flow = .signUp(.questions(n, e, p, .signingUp(bm, mf, .notSent(nil, "Unknown error"))))
      return .none
    case let (.signUp(.questions(n, e, p, .answering(ebmmf, _, _))), .businessManagesSelected):
      state.flow = .signUp(.questions(n, e, p, .answering(ebmmf, .left(.businessManages), nil)))
      return .none
    case let (.signUp(.questions(n, e, p, .answering(ebmmf, _, _))), .managesForSelected):
      state.flow = .signUp(.questions(n, e, p, .answering(ebmmf, .left(.managesFor), nil)))
      return .none
    case let (.signUp(.questions(n, e, p, .answering(ebmmf, .left, _))), .dismissFocus),
         let (.signUp(.questions(n, e, p, .answering(ebmmf, .none, _))), .dismissFocus):
      state.flow = .signUp(.questions(n, e, p, .answering(ebmmf, nil, nil)))
      return .none
    case let (.signUp(.questions(n, e, p, .answering(ebmmf, _, _))), .businessManagesChanged(newBM)):
      switch (ebmmf, newBM) {
      case let (.none, .some(newBM)),
           let (.left, .some(newBM)):
        state.flow = .signUp(.questions(n, e, p, .answering(.left(newBM), .left(.businessManages), nil)))
      case let (.right(mf), .some(newBM)):
        state.flow = .signUp(.questions(n, e, p, .signingUp(newBM, mf, .notSent(.businessManages, nil))))
      case (.left, .none):
        state.flow = .signUp(.questions(n, e, p, .answering(nil, .left(.businessManages), nil)))
      case (.some(.right), .none),
           (.none, .none):
        break
      }
      return .none
    case let (.signUp(.questions(n, e, p, .answering(ebmmf, _, _))), .managesForChanged(newMF)):
      switch (ebmmf, newMF) {
      case let (.none, .some(newMF)),
           let (.right, .some(newMF)):
        state.flow = .signUp(.questions(n, e, p, .answering(.right(newMF), .left(.managesFor), nil)))
      case let (.left(bm), .some(newMF)):
        state.flow = .signUp(.questions(n, e, p, .signingUp(bm, newMF, .notSent(.managesFor, nil))))
      case (.right, .none):
        state.flow = .signUp(.questions(n, e, p, .answering(nil, .left(.managesFor), nil)))
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
    case let (.signUp(.verification(.entered(c, .inFlight), e, p)), .autoSignInFailed(error)):
      state.flow = .signUp(.verification(.entering(nil, .unfocused, error, nil), e, p))
      return .none
    case let (.signUp(.verification(.entered(c, .notSent(.unfocused, error, nil)), e, p)), .focusVerification):
      state.flow = .signUp(.verification(.entered(c, .notSent(.focused, error, nil)), e, p))
      return .none
    case let (.signUp(.verification(.entering(c, .unfocused, er, nil), e, p)), .focusVerification):
      state.flow = .signUp(.verification(.entering(c, .focused, er, nil), e, p))
      return .none
    case let (.signUp(.verification(.entered(c, .notSent(.focused, error, nil)), e, p)), .dismissFocus):
      state.flow = .signUp(.verification(.entered(c, .notSent(.unfocused, error, nil)), e, p))
      return .none
    case let (.signUp(.verification(.entering(c, .focused, er, nil), e, p)), .dismissFocus):
      state.flow = .signUp(.verification(.entering(c, .unfocused, er, nil), e, p))
      return .none
    case let (.signUp(.verification(.entering(nil, f, er, nil), e, p)), .firstVerificationFieldChanged(s)):
      if let verification = VerificationCode(string: s) {
        return Effect(value: AppAction.verificationExtractedFromPasteboard(verification))
      } else {
        if let digit = VerificationCode.Digit(string: s) {
          state.flow = .signUp(.verification(.entering(.one(digit), f, er, nil), e, p))
        }
        return .none
      }
    case let (.signUp(.verification(.entering(.one(d), f, er, nil), e, p)), .secondVerificationFieldChanged(s)):
      if let digit = VerificationCode.Digit(string: s) {
        state.flow = .signUp(.verification(.entering(.two(d, digit), f, er, nil), e, p))
      }
      return .none
    case let (.signUp(.verification(.entering(.two(d1, d2), f, er, nil), e, p)), .thirdVerificationFieldChanged(s)):
      if let digit = VerificationCode.Digit(string: s) {
        state.flow = .signUp(.verification(.entering(.three(d1, d2, digit), f, er, nil), e, p))
      }
      return .none
    case let (.signUp(.verification(.entering(.three(d1, d2, d3), f, er, nil), e, p)), .fourthVerificationFieldChanged(s)):
      if let digit = VerificationCode.Digit(string: s) {
        state.flow = .signUp(.verification(.entering(.four(d1, d2, d3, digit), f, er, nil), e, p))
      }
      return .none
    case let (.signUp(.verification(.entering(.four(d1, d2, d3, d4), f, er, nil), e, p)), .fifthVerificationFieldChanged(s)):
      if let digit = VerificationCode.Digit(string: s) {
        state.flow = .signUp(.verification(.entering(.five(d1, d2, d3, d4, digit), f, er, nil), e, p))
      }
      return .none
    case let (.signUp(.verification(.entering(.five(d1, d2, d3, d4, d5), f, er, nil), e, p)), .sixthVerificationFieldChanged(s)):
      if let digit = VerificationCode.Digit(string: s) {
        let verificationCode = VerificationCode(first: d1, second: d2, third: d3, fourth: d4, fifth: d5, sixth: digit)
        state.flow = .signUp(.verification(.entered(verificationCode, .inFlight), e, p))
        return verify(email: e, password: p, code: verificationCode)
      }
      return .none
    case let (.signUp(.verification(stage, e, p)), .deleteVerificationDigit):
      switch stage {
      case let .entered(c, .notSent(_, er, _)):
        state.flow = .signUp(.verification(.entering(.five(c.first, c.second, c.third, c.fourth, c.fifth), .focused, er, nil), e, p))
      case let .entering(.five(d1, d2, d3, d4, _), _, er, _):
        state.flow = .signUp(.verification(.entering(.four(d1, d2, d3, d4), .focused, er, nil), e, p))
      case let .entering(.four(d1, d2, d3, _), _, er, _):
        state.flow = .signUp(.verification(.entering(.three(d1, d2, d3), .focused, er, nil), e, p))
      case let .entering(.three(d1, d2, _), _, er, _):
        state.flow = .signUp(.verification(.entering(.two(d1, d2), .focused, er, nil), e, p))
      case let .entering(.two(d1, _), _, er, _):
        state.flow = .signUp(.verification(.entering(.one(d1), .focused, er, nil), e, p))
      case let .entering(.one, _, er, _):
        state.flow = .signUp(.verification(.entering(nil, .focused, er, nil), e, p))
      default:
        break
      }
      return .none
    case let (.signUp(.verification(.entering, e, p)), .resendVerificationCode),
         let (.signUp(.verification(.entered(_, .notSent), e, p)), .resendVerificationCode):
      return .merge(
        environment.api
          .resendVerificationCode(e)
          .flatMap { (result: Result<ResendVerificationResponse, APIError>) -> Effect<AppAction, Never> in
            
            let makeSDKBaked = makeSDK(DriverID(rawValue: e.rawValue))
            
            switch result {
            case .success(.success):
              return .none
            case .success(.alreadyVerified):
              return environment.api
                .signIn(e, p)
                .receive(on: environment.mainQueue())
                .eraseToEffect()
                .flatMap { (result: Result<PublishableKey, APIError>) -> Effect<AppAction, Never> in
                  switch result {
                  case let .success(pk):
                    return makeSDKBaked(pk)
                  case let .failure(error):
                    return Effect(value: AppAction.autoSignInFailed(SignUpError(rawValue: "Unknown error")))
                  }
                }
                .eraseToEffect()
            case let .success(.error(error)):
              return Effect(value: AppAction.autoSignInFailed(SignUpError(rawValue: error)))
            case let .failure(error):
              return Effect(value: AppAction.autoSignInFailed(SignUpError(rawValue: "Unknown error")))
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
    
    struct SignInID: Hashable {}
    
    switch state.flow {
    case let .signIn(.editingCredentials(emailAndPassword, focusAndDeeplink)):
      if case .right = focusAndDeeplink {
        return .none
      } else {
        let focusAndError: These<SignInFocus, SignInError>?
        if case let .left(f) = focusAndDeeplink {
          focusAndError = f
        } else {
          focusAndError = nil
        }
        switch action {
        case .emailChanged(.none):
          switch emailAndPassword {
          case .none, .some(.that): break
          case let .some(.both(_, password)):
            state.flow = .signIn(.editingCredentials(.that(password), focusAndDeeplink))
          case .some(.this):
            state.flow = .signIn(.editingCredentials(.none, focusAndDeeplink))
          }
          return .none
        case let .emailChanged(.some(e)):
          switch emailAndPassword {
          case .none:
            state.flow = .signIn(.editingCredentials(.this(e), focusAndDeeplink))
          case let .some(.both(_, password)):
            state.flow = .signIn(.editingCredentials(.both(e, password), focusAndDeeplink))
          case .some(.this):
            state.flow = .signIn(.editingCredentials(.this(e), focusAndDeeplink))
          case let .some(.that(password)):
            state.flow = .signIn(.editingCredentials(.both(e, password), focusAndDeeplink))
          }
          return .none
        case .focusEmail:
          switch focusAndError {
          case .none, .this:
            state.flow = .signIn(.editingCredentials(emailAndPassword, .left(.this(.email))))
          case let .some(.both(_, error)),
               let .some(.that(error)):
            state.flow = .signIn(.editingCredentials(emailAndPassword, .left(.both(.email, error))))
          }
          return .none
        case .focusPassword:
          switch focusAndError {
          case .none, .this:
            state.flow = .signIn(.editingCredentials(emailAndPassword, .left(.this(.password))))
          case let .some(.both(_, error)),
               let .some(.that(error)):
            state.flow = .signIn(.editingCredentials(emailAndPassword, .left(.both(.password, error))))
          }
          return .none
        case .passwordChanged(.none):
          switch emailAndPassword {
          case .none, .some(.this): break
          case let .some(.both(email, _)):
            state.flow = .signIn(.editingCredentials(.this(email), focusAndDeeplink))
          case .some(.that):
            state.flow = .signIn(.editingCredentials(.none, focusAndDeeplink))
          }
          return .none
        case let .passwordChanged(.some(p)):
          switch emailAndPassword {
          case .none:
            state.flow = .signIn(.editingCredentials(.that(p), focusAndDeeplink))
          case let .some(.both(email, _)):
            state.flow = .signIn(.editingCredentials(.both(email, p), focusAndDeeplink))
          case .some(.that):
            state.flow = .signIn(.editingCredentials(.that(p), focusAndDeeplink))
          case let .some(.this(email)):
            state.flow = .signIn(.editingCredentials(.both(email, p), focusAndDeeplink))
          }
          return .none
        case .signIn:
          if case let .both(e, p) = emailAndPassword {
            state.flow = .signIn(.signingIn(e, p))
            return environment.api
              .signIn(e, p)
              .receive(on: environment.mainQueue())
              .eraseToEffect()
              .map(AppAction.signedIn)
              .cancellable(id: SignInID(), cancelInFlight: true)
          } else {
            return .none
          }
        case .dismissFocus:
          switch focusAndError {
          case .none, .some(.this):
            state.flow = .signIn(.editingCredentials(emailAndPassword, .none))
            return .none
          case let .some(.both(_, e)),
               let .some(.that(e)):
            state.flow = .signIn(.editingCredentials(emailAndPassword, .left(.that(e))))
            return .none
          }
        default:
          return .none
        }
      }
    case let .signIn(.signingIn(e, p)):
      switch action {
      case .cancelSignIn:
        state.flow = .signIn(.editingCredentials(.both(e, p), nil))
        return .cancel(id: SignInID())
      case let .signedIn(.success(pk)):
        state.flow = .driverID(nil, pk, nil)
        return .none
      case let .signedIn(.failure(error)):
        state.flow = .signIn(.editingCredentials(.both(e, p), .left(.that("Unknown error"))))
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
    case let .driverID(drID, pk, .none):
      switch action {
      case let .driverIDChanged(newDrID):
        state.flow = .driverID(newDrID, pk, .none)
        return .none
      case .setDriverID:
        if let drID = drID {
          return environment.hyperTrack
            .makeSDK(pk)
            .receive(on: environment.mainQueue())
            .eraseToEffect()
            .map(AppAction.madeSDK)
        }
        return .none
      case .madeSDK(.locked, _):
        state.flow = .noMotionServices
        return .none
      case let .madeSDK(.unlocked(deID, us), p):
        if let drID = drID {
          state.flow = .visits([], nil, nil, .defaultTab, pk, drID, deID, us, p, nil, .dialogSplash(.notShown), .firstRun, nil)
          return .concatenate(
            environment.hyperTrack
              .subscribeToStatusUpdates()
              .receive(on: environment.mainQueue())
              .eraseToEffect()
              .map(AppAction.statusUpdated),
            environment.hyperTrack
              .setDriverID(drID)
              .receive(on: environment.mainQueue())
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
  // Visits
  Reducer { state, action, environment in
    switch state.flow {
    case let .visits(v, sv, h, s, pk, drID, deID, us, p, r, ps, e, d):
      let getVisits = getVisitsEffect(environment.api.getVisits(pk, deID), environment.mainQueue())
      let getHistory = getHistoryEffect(environment.api.getHistory(pk, deID, environment.date()), environment.mainQueue())
      let fvs = filterOutOldVisits(environment.date())(v)
      let fv = filterOutOldVisit(environment.date())(sv)
      
      
      switch action {
      case .willEnterForeground,
           .receivedPushNotification:
        var effects: [Effect<AppAction, Never>] = []
        switch r {
        case .none:
          effects += [getVisits, getHistory]
        case .some(.this):
          effects += [getHistory]
        case .some(.that):
          effects += [getVisits]
        case .some(.both):
          return .none
        }
        state.flow = .visits(fvs, fv, h, s, pk, drID, deID, us, p, .both(RefreshingVisits(), RefreshingHistory()), ps, e, d)
        return .merge(effects)
      case .updateVisits:
        let effect: Effect<AppAction, Never>
        let refreshing: These<RefreshingVisits, RefreshingHistory>
        switch r {
        case .none, .some(.that):
          effect = getVisits
        case .some(.this), .some(.both):
          effect = .none
        }
        switch r {
        case .none, .some(.this):
          refreshing = .this(RefreshingVisits())
        case .some(.that), .some(.both):
          refreshing = .both(RefreshingVisits(), RefreshingHistory())
        }
        state.flow = .visits(fvs, fv, h, s, pk, drID, deID, us, p, refreshing, ps, e, d)
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
      case let .selectVisit(str):
        let (v, sv) = selectVisit(v: v, sv: sv, id: str)
        state.flow = .visits(v, sv, h, .visits, pk, drID, deID, us, p, r, ps, e, d)
        return .none
      case .cancelVisit:
        if var sv = sv, sv.geotagSent.checkedOut == nil, sv.geotagSent.cancelled == nil {
          sv.geotagSent = .cancelled(sv.geotagSent.isVisited, environment.date())
          state.flow = .visits(v, sv, h, s, pk, drID, deID, us, p, r, ps, e, d)
          return .merge(
            environment.hyperTrack
              .addGeotag(.cancel(sv.id, sv.source, sv.visitNote))
              .fireAndForget(),
            environment.hapticFeedback
              .notifySuccess()
              .fireAndForget()
          )
        } else {
          return .none
        }
      case .checkOutVisit:
        guard var sv = sv, sv.geotagSent.checkedOut == nil, sv.geotagSent.cancelled == nil else {
          return .none
        }
        sv.geotagSent = .checkedOut(sv.geotagSent.isVisited, environment.date())
        state.flow = .visits(v, sv, h, s, pk, drID, deID, us, p, r, ps, e, d)
        return .merge(
          environment.hyperTrack
            .addGeotag(.checkOut(sv.id, sv.source, sv.visitNote))
            .fireAndForget(),
          environment.hapticFeedback
            .notifySuccess()
            .fireAndForget()
        )
      case let .visitNoteChanged(n):
        guard var sv = sv else { return .none }
        
        sv.visitNote = n >>- Visit.VisitNote.init(rawValue:)
        
        state.flow = .visits(v, sv, h, s, pk, drID, deID, us, p, r, ps, e, d)
        return .none
      case .deselectVisit:
        state.flow = .visits(sv.map { Set.insert($0)(v) } ?? v, nil, h, s, pk, drID, deID, us, p, r, ps, e, d)
        return .none
      case .focusVisitNote:
        guard var sv = sv else { return .none }
        
        sv.noteFieldFocused = true
        
        state.flow = .visits(v, sv, h, s, pk, drID, deID, us, p, r, ps, e, d)
        return .none
      case .openAppleMaps:
        guard var sv = sv else { return .none }
        
        let add: Either<Visit.FullAddress, Visit.Street>?
        switch sv.address {
        case .none:
          add = .none
        case let .some(.both(_, f)),
             let .some(.that(f)):
          add = .left(f)
        case let .some(.this(a)):
          add = .right(a)
        }
        
        return environment.maps
          .openMap(sv.location, add)
          .fireAndForget()
      case .pickUpVisit:
        guard var sv = sv, sv.geotagSent == .notSent else { return .none }
        
        sv.geotagSent = .pickedUp
        
        state.flow = .visits(v, sv, h, s, pk, drID, deID, us, p, r, ps, e, d)
        
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
        
        state.flow = .visits(v, sv, h, s, pk, drID, deID, us, p, r, ps, e, d)
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
          .receive(on: environment.mainQueue())
          .eraseToEffect()
          .map(AppAction.statusUpdated)
      case .requestPushAuthorization:
        state.flow = .visits(v, sv, h, s, pk, drID, deID, us, p, r, .dialogSplash(.waitingForUserAction), e, d)
        return environment.push
          .requestAuthorization()
          .receive(on: environment.mainQueue())
          .map(constant(AppAction.userHandledPushAuthorization))
          .eraseToEffect()
      case .userHandledPushAuthorization:
        state.flow = .visits(v, sv, h, s, pk, drID, deID, us, p, r, .dialogSplash(.shown), e, d)
        return .none
      case let .statusUpdated(st, p):
        switch st {
        case .locked:
          state.flow = .noMotionServices
        case let .unlocked(deID, us):
          state.flow = .visits(v, sv, h, s, pk, drID, deID, us, p, r, ps, e, d)
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
        switch r {
        case .none:
          effects += [getVisits, getHistory]
        case .some(.this):
          effects += [getHistory]
        case .some(.that):
          effects += [getVisits]
        case .some(.both):
          break
        }
        state.flow = .visits(fvs, fv, h, s, pk, drID, deID, us, p, .both(RefreshingVisits(), RefreshingHistory()), ps, e, d)
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
        switch r {
        case .none:
          break
        case .some(.this):
          effects += [.cancel(id: RefreshingVisitsID())]
        case .some(.that):
          effects += [.cancel(id: RefreshingHistoryID())]
        case .some(.both):
          effects += [
            .cancel(id: RefreshingVisitsID()),
            .cancel(id: RefreshingHistoryID())
          ]
        }
        state.flow = .visits(v, sv, h, s, pk, drID, deID, us, p, .none, ps, e, d)
        return .merge(effects)
      case let .reverseGeocoded(g):
        state.flow = .visits(updateAddress(for: v, with: g), sv <¡> updateAddress(with: g), h, s, pk, drID, deID, us, p, r, ps, e, d)
        return .none
      case let .visitsUpdated(vs):
        let allVs = sv.map { Set.insert($0)(v) } ?? v
        let updatedVs = (resultSuccess(vs) <¡> update(allVs)) ?? allVs
        let freshVs = updatedVs |> filterOutOldVisits(environment.date())
        
        let (nv, nsv): (Set<Visit>, Visit?)
        if let id = sv?.id.rawValue.rawValue {
          (nv, nsv) = selectVisit(v: freshVs, sv: nil, id: id)
        } else {
          (nv, nsv) = (freshVs, nil)
        }
        
        state.flow = .visits(nv, nsv, h, s, pk, drID, deID, us, p, r >>- removeThis, ps, e, d)
        if let reverseGeocodingCoordinates = NonEmptySet(rawValue: visitCoordinatesWithoutAddress(freshVs)) {
          return environment.api
            .reverseGeocode(reverseGeocodingCoordinates.map(identity))
            .map { $0.map { GeocodedResult(coordinate: $0.0, address: $0.1) } }
            .receive(on: environment.mainQueue())
            .eraseToEffect()
            .map(AppAction.reverseGeocoded)
        } else {
          return .none
        }
      case let .historyUpdated(h):
        state.flow = .visits(v, sv, resultSuccess(h), s, pk, drID, deID, us, p, r >>- removeThat, ps, e, d)
        return .none
      default:
        return .none
      }
    default:
      return .none
    }
  },
  // TabView
  Reducer { state, action, environment in
    switch (state.flow, action) {
    case let (.visits(v, sv, h, s, pk, drID, deID, us, p, r, ps, e, d), .switchToVisits) where s != .visits:
      state.flow = .visits(v, sv, h, .visits, pk, drID, deID, us, p, r, ps, e, d)
      return Effect(value: .updateVisits)
    case let (.visits(v, sv, h, s, pk, drID, deID, us, p, r, ps, e, d), .switchToMap) where s != .map:
      state.flow = .visits(v, sv, h, .map, pk, drID, deID, us, p, r, ps, e, d)
      
      let effect: Effect<AppAction, Never>
      let refreshing: These<RefreshingVisits, RefreshingHistory>
      switch r {
      case .none, .some(.this):
        effect = getHistoryEffect(environment.api.getHistory(pk, deID, environment.date()), environment.mainQueue())
      case .some(.that), .some(.both):
        effect = .none
      }
      switch r {
      case .none, .some(.that):
        refreshing = .that(RefreshingHistory())
      case .some(.this), .some(.both):
        refreshing = .both(RefreshingVisits(), RefreshingHistory())
      }
      state.flow = .visits(v, sv, h, .map, pk, drID, deID, us, p, refreshing, ps, e, d)
      return effect
    case let (.visits(v, sv, h, s, pk, drID, deID, us, p, r, ps, e, d), .switchToSummary) where s != .summary:
      state.flow = .visits(v, sv, h, .summary, pk, drID, deID, us, p, r, ps, e, d)
      return .none
    case let (.visits(v, sv, h, s, pk, drID, deID, us, p, r, ps, e, d), .switchToProfile) where s != .profile:
      state.flow = .visits(v, sv, h, .profile, pk, drID, deID, us, p, r, ps, e, d)
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
      case (.visits, .visits): return effects
      case let (_, .visits(v, sv, h, s, pk, drID, deID, us, p, r, ps, e, d)):
        let getVisits = getVisitsEffect(environment.api.getVisits(pk, deID), environment.mainQueue())
        let getHistory = getHistoryEffect(environment.api.getHistory(pk, deID, environment.date()), environment.mainQueue())
        
        var effects: [Effect<AppAction, Never>] = [effects]
        switch r {
        case .none:
          effects += [getVisits, getHistory]
        case .some(.this):
          effects += [getHistory]
        case .some(.that):
          effects += [getVisits]
        case .some(.both):
          return .none
        }
        
        state.flow = .visits(v, sv, h, s, pk, drID, deID, us, p, .both(RefreshingVisits(), RefreshingHistory()), ps, e, d)
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
      case let .visits(v, sv, h, s, pk, drID, deID, .stopped, p, .none, .dialogSplash(.shown), .firstRun, .none)
            where p.locationAccuracy == .full
            && p.locationPermissions == .authorized
            && p.motionPermissions == .authorized:
        
        let getVisits = getVisitsEffect(environment.api.getVisits(pk, deID), environment.mainQueue())
        let getHistory = getHistoryEffect(environment.api.getHistory(pk, deID, environment.date()), environment.mainQueue())
        let combinedEffects: [Effect<AppAction, Never>] = [
          effects,
          environment.hyperTrack
            .startTracking()
            .fireAndForget(),
          getVisits,
          getHistory
        ]
        state.flow = .visits(v, sv, h, s, pk, drID, deID, .running, p, .both(RefreshingVisits(), RefreshingHistory()), .dialogSplash(.shown), .regular, .none)
        return .merge(combinedEffects)
      default: return effects
      }
    }
  }
}

public func resultSuccess<Success, Failure>(_ r: Result<Success, Failure>) -> Success? {
  try? r.get()
}

func selectVisit(v: Set<Visit>, sv: Visit?, id: String) -> (Set<Visit>, Visit?) {
  let v = combine(v, sv)
  let sv: Visit? = v.firstIndex(where: { $0.id.rawValue.rawValue == id }).map { v[$0] }
  return (v.filter { $0.id.rawValue.rawValue != id }, sv)
}

func update(_ vs: Set<Visit>) -> ([APIVisitID: APIVisit]) -> Set<Visit> {
  { apiVisits in
    Set(
      apiVisits.map { tuple in
        if let match = vs.first(where: { tuple.key.rawValue == $0.id.rawValue }) {
          return update(visit: match, with: (tuple.key, tuple.value))
        } else {
          return Visit(apiVisit: (tuple.key, tuple.value))
        }
      }
      +
      vs.compactMap { v in
        if apiVisits[rewrap(v.id)] == nil {
          return v
        } else {
          return nil
        }
      }
    )
  }
}

func combine(_ v: Set<Visit>, _ sv: Visit?) -> Set<Visit> {
  sv.map { Set.insert($0)(v) } ?? v
}


func update(visit: Visit?, with apiVisit: (id: APIVisitID, visit: APIVisit) ) -> Visit {
  guard var visit = visit else { return .init(apiVisit: apiVisit) }

  visit.geotagSent.isVisited = apiVisit.visit.visitStatus.map(Visit.Geotag.Visited.init(visitStatus:))
  
  return visit
}

extension Visit.Geotag.Visited {
  init(visitStatus: VisitStatus) {
    switch visitStatus {
    case let .entered(entry): self = .entered(entry)
    case let .visited(entry, exit): self = .visited(entry, exit)
    }
  }
}

extension Visit {
  init(apiVisit: (id: APIVisitID, visit: APIVisit)) {
    let source: Visit.Source
    switch apiVisit.visit.source {
    case .geofence: source = .geofence
    case .trip: source = .trip
    }
    
    self.init(
      id: rewrap(apiVisit.id),
      createdAt: apiVisit.visit.createdAt,
      source: source,
      location: apiVisit.visit.centroid,
      geotagSent: .notSent,
      noteFieldFocused: false,
      address: nil,
      visitNote: nil,
      metadata: rewrapDictionary(apiVisit.visit.metadata)
    )
  }
}

func rewrapDictionary<A, B, C, D, E, F>(_ dict: Dictionary<Tagged<A, B>, Tagged<C, D>>) -> Dictionary<Tagged<E, B>, Tagged<F, D>> {
  Dictionary(uniqueKeysWithValues: dict.map { (rewrap($0), rewrap($1)) })
}

func rewrap<Source, Value, Destination>(_ source: Tagged<Source, Value>) -> Tagged<Destination, Value> {
  .init(rawValue: source.rawValue)
}

func visitCoordinatesWithoutAddress(_ visits: Set<Visit>) -> Set<Coordinate> {
  Set(visits.compactMap { $0.address == nil ? $0.location : nil })
}

func updateAddress(for visits: Set<Visit>, with geocodedResults: [GeocodedResult]) -> Set<Visit> {
  Set(visits.map(updateAddress(with: geocodedResults)))
}

func updateAddress(with geocodedResults: [GeocodedResult]) -> (Visit) -> Visit {
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
