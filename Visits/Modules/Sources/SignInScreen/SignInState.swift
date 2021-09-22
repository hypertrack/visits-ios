import Types


enum SignInButtonState { case normal, destructive, disabled }

extension SignInState {
  var buttonState: SignInButtonState {
    switch self {
    case let .entering(eg):
      switch (eg.email, eg.password) {
      case (.some, .some): return .normal
      default:             return .disabled
      }
    case let .entered(ed):
      switch ed.request {
      case .inFlight:      return .destructive
      case .success:       return .disabled
      }
    }
  }

  var email: String {
    switch self {
    case let .entering(eg): return eg.email?.string ?? ""
    case let .entered(ed):  return ed.email.string
    }
  }

  var errorMessage: String {
    switch self {
    case let .entering(eg): return eg.error?.string ?? ""
    case .entered:          return ""
    }
  }

  var password: String {
    switch self {
    case let .entering(eg): return eg.password?.string ?? ""
    case let .entered(ed):  return ed.password.string
    }
  }

  var signingIn: Bool {
    switch self {
    case .entering: return false
    case .entered:  return true
    }
  }

  var fieldInFocus: SignInState.Entering.Focus? {
    switch self {
    case let .entering(eg):
      switch eg.focus {
      case .none:            return .none
      case .some(.email):    return .email
      case .some(.password): return .password
      }
    case .entered:           return .none
    }
  }
}
