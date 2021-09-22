public enum SignInScreenAction {
  case cancelSignInTapped
  case emailChanged(String)
  case emailEnterKeyboardButtonTapped
  case emailTapped
  case passwordChanged(String)
  case passwordEnterKeyboardButtonTapped
  case passwordTapped
  case signInTapped
  case tappedOutsideFocus
}

func lift(to send: @escaping (SignInScreenAction) -> Void) -> (PasswordField.Action) -> Void {
  { action in
    switch action {
    case let .passwordChanged(p):                send(.passwordChanged(p))
    case     .passwordEnterKeyboardButtonTapped: send(.passwordEnterKeyboardButtonTapped)
    case     .passwordTapped:                    send(.passwordTapped)
    }
  }
}

func lift(to send: @escaping (SignInScreenAction) -> Void) -> (EmailField.Action) -> Void {
  { action in
    switch action {
    case let .emailChanged(e):                send(.emailChanged(e))
    case     .emailEnterKeyboardButtonTapped: send(.emailEnterKeyboardButtonTapped)
    case     .emailTapped:                    send(.emailTapped)
    }
  }
}
