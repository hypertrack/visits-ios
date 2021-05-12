import ComposableArchitecture
import Types


// MARK: - State

public enum SignUpSignInToggleState: Equatable {
  case signUp(SignUpState)
  case signIn(SignInState)
}

// MARK: - Action

public enum SignUpSignInToggleAction: Equatable {
  case goToSignUp
  case goToSignIn
}

// MARK: - Reducer

public let signUpSignInToggleReducer = Reducer<
  SignUpSignInToggleState,
  SignUpSignInToggleAction,
  Void
> { state, action, _ in
  switch action {
  case .goToSignUp:
    guard case let .signIn(signIn) = state else { return .none }
    
    state = .signUp(.form(.init(status: .filling(.init(email: signIn.email)))))
    
    return .none
  case .goToSignIn:
    guard case let .signUp(signUp) = state else { return .none }
    
    state = .signIn(.entering(.init(email: signUp.email)))
    
    return .none
  }
}

extension SignInState {
  var email: Email? {
    switch self {
    case let .entering(eg): return eg.email
    case let .entered(ed):  return ed.email
    }
  }
}

extension SignUpState {
  var email: Email? {
    switch self {
    case let .form(f):
      switch f.status {
      case let .filling(f):    return f.email
      case let .filled(f):     return f.email
      }
    case let .questions(q):    return q.email
    case let .verification(v): return v.email
    }
  }
}
