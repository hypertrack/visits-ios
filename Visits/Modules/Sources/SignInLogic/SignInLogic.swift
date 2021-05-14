import AppArchitecture
import ComposableArchitecture
import Prelude
import Types


// MARK: - Action

public enum SignInAction: Equatable {
  case focusEmail
  case focusPassword
  case dismissFocus
  case emailChanged(Email?)
  case passwordChanged(Password?)
  case signIn
  case cancelSignIn
  case signedIn(Result<PublishableKey, APIError<CognitoError>>)
  case madeSDK(SDKStatusUpdate)
}

// MARK: - Environment

public struct SignInEnvironment {
  public var makeSDK: (PublishableKey) -> Effect<SDKStatusUpdate, Never>
  public var signIn: (Email, Password) -> Effect<Result<PublishableKey, APIError<CognitoError>>, Never>
  
  public init(
    makeSDK: @escaping (PublishableKey) -> Effect<SDKStatusUpdate, Never>,
    signIn: @escaping (Email, Password) -> Effect<Result<PublishableKey, APIError<CognitoError>>, Never>
  ) {
    self.makeSDK = makeSDK
    self.signIn = signIn
  }
}

// MARK: - Reducer

struct SignInID: Hashable {}

public func cancelSignInEffects<Action>() -> Effect<Action, Never> { .cancel(id: SignInID()) }

public let signInReducer = Reducer<SignInState, SignInAction, SystemEnvironment<SignInEnvironment>> { state, action, environment in
  switch action {
  case .focusEmail:
    guard case let .entering(eg) = state else { return .none }
    
    state = .entering(eg |> \.focus *< .email)
    
    return .none
  case .focusPassword:
    guard case let .entering(eg) = state else { return .none }
    
    state = .entering(eg |> \.focus *< .password)
    
    return .none
  case .dismissFocus:
    guard case let .entering(eg) = state else { return .none }
    
    state = .entering(eg |> \.focus *< nil)
    
    return .none
  case let .emailChanged(e):
    guard case let .entering(eg) = state else { return .none }
    
    let e = e >>- { $0.cleanup() }
    state = .entering(eg |> \.email *< e)
    
    return .none
  case let .passwordChanged(p):
    guard case let .entering(eg) = state else { return .none }
    
    state = .entering(eg |> \.password *< p)
    
    return .none
  case .signIn:
    guard case let .entering(eg) = state else { return .none }
    
    let error = { (e: CognitoError, s: inout SignInState) in s = .entering(eg |> \.error *< e) }
    switch (eg.email, eg.password) {
    case (.none, _):
      error("Please enter a valid email ID", &state)
    case let (.some(e), _) where !e.isValid():
      error("Please enter a valid email ID", &state)
    case (_, .none):
      error("Password should be 8 characters or more", &state)
    case let (_, .some(p)) where !p.isValid():
      error("Password should be 8 characters or more", &state)
    case let (.some(e), .some(p)):
      state = .entered(.init(email: e, password: p, request: .inFlight))
      return environment.signIn(e, p)
        .receive(on: environment.mainQueue)
        .eraseToEffect()
        .map(SignInAction.signedIn)
        .cancellable(id: SignInID(), cancelInFlight: true)
    }
    
    return .none
  case .cancelSignIn:
    guard case let .entered(ed) = state, ed.request == .inFlight else { return .none }
    
    state = .entering(.init(email: ed.email, password: ed.password, focus: nil, error: nil))
    
    return .cancel(id: SignInID())
  case let .signedIn(.success(pk)):
    guard case let .entered(ed) = state, ed.request == .inFlight else { return .none }
    
    state = .entered(ed |> \.request *< .success(pk))
    
    return environment.makeSDK(pk)
      .receive(on: environment.mainQueue)
      .map(SignInAction.madeSDK)
      .eraseToEffect()
      
  case let .signedIn(.failure(e)):
    guard case let .entered(ed) = state, ed.request == .inFlight else { return .none }
    
    state = .entering(.init(email: ed.email, password: ed.password, focus: nil, error: e *^? /APIError<CognitoError>.error))
    
    return .none
  case .madeSDK:
    return .none
  }
}
