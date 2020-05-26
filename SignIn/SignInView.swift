import Combine
import SwiftUI

import ComposableArchitecture

import ViewsComponents


public struct SignInView: View {
  struct State: Equatable {
    let emailTextFieldValue: String
    let errorMessage: String
    let passwordTextFieldValue: String
    let signingIn: Bool
    let textFieldInFocus: Focus
    
    var signInButtonDisabled: Bool { emailTextFieldValue.isEmpty || passwordTextFieldValue.isEmpty }
    var signInButtonState: PrimaryButton.State {
      if signingIn {
        return .destructive
      } else if signInButtonDisabled {
        return .disabled
      } else {
        return .normal
      }
    }
  }
  enum Action {
    case cancelSignInTapped
    case emailEnterKeyboardButtonTapped
    case emailFieldChanged(String)
    case emailTapped
    case forgotPasswordTapped
    case passwordEnterKeyboardButtonTapped
    case passwordFieldChanged(String)
    case passwordTapped
    case signInTapped
    case signUpTapped
    case tappedOutsideFocusedTextField
  }
  
  let store: Store<SignInState, SignInAction>
  @ObservedObject private var viewStore: ViewStore<SignInView.State, SignInView.Action>
  
  public init(store: Store<SignInState, SignInAction>) {
    self.store = store
    self.viewStore = ViewStore(
      self.store.scope(
        state: State.init(signInState:),
        action: SignInAction.init
      )
    )
  }
  
  public var body: some View {
    VStack {
      TitleView(title: "Sign in to your account")
      PrimaryTextField(
        placeholder: "Email address",
        text: viewStore.binding(
          get: \.emailTextFieldValue,
          send: { .emailFieldChanged($0) }
        ),
        isFocused: viewStore.textFieldInFocus == .email,
        errorText: "",
        textContentType: .emailAddress,
        keyboardType: .emailAddress,
        returnKeyType: .next,
        wantsToBecomeFocused: { self.viewStore.send(.emailTapped) },
        onEnterButtonPressed: { self.viewStore.send(.emailEnterKeyboardButtonTapped) }
      )
        .disabled(viewStore.signingIn)
        .padding(.top, 50)
        .padding([.trailing, .leading], 16)
      SecureTextField(
        placeholder: "Password",
        text: viewStore.binding(
          get: \.passwordTextFieldValue,
          send: { .passwordFieldChanged($0) }
        ),
        isFocused: viewStore.textFieldInFocus == .password,
        errorText: viewStore.errorMessage,
        returnKeyType: .send,
        wantsToBecomeFocused: { self.viewStore.send(.passwordTapped) },
        onEnterButtonPressed: { self.viewStore.send(.passwordEnterKeyboardButtonTapped) }
      )
        .disabled(viewStore.signingIn)
        .padding(.top, 17)
        .padding([.trailing, .leading], 16)
      PrimaryButton(
        state: viewStore.signInButtonState,
        isActivityVisible: viewStore.signingIn,
        title: "Sign in"
      ) { self.viewStore.signingIn ? self.viewStore.send(.cancelSignInTapped) : self.viewStore.send(.signInTapped) }
        .padding(.top, 39)
        .padding([.trailing, .leading], 58)
      Spacer()
    }
    .modifier(AppBackground())
    .edgesIgnoringSafeArea(.all)
    .onTapGesture {
      if .none != self.viewStore.textFieldInFocus {
        self.viewStore.send(.tappedOutsideFocusedTextField)
      }
    }
  }
}

extension SignInView.State {
  init(signInState: SignInState) {
    switch signInState.credentials {
    case let .incomplete(credentials):
      switch credentials.fields {
      case let .emailEntered(email):
        self.emailTextFieldValue = email.rawValue
        self.passwordTextFieldValue = ""
      case .empty:
        self.emailTextFieldValue = ""
        self.passwordTextFieldValue = ""
      case let .passwordEntered(password):
        self.emailTextFieldValue = ""
        self.passwordTextFieldValue = password.rawValue
      }
      self.errorMessage = credentials.state.error
      self.signingIn = false
      self.textFieldInFocus = credentials.state.focus
    case let .complete(credentials):
      self.emailTextFieldValue = credentials.email.rawValue
      self.passwordTextFieldValue = credentials.password.rawValue
      switch credentials.requestStatus {
      case .inFlight:
        self.errorMessage = ""
        self.signingIn = true
        self.textFieldInFocus = .none
      case let .notSent(status):
        self.errorMessage = status.error
        self.signingIn = false
        self.textFieldInFocus = status.focus
      }
    }
  }
}

extension SignInAction {
  init(action: SignInView.Action) {
    switch action {
    case .cancelSignInTapped:
      self = .cancelSignIn
    case .emailEnterKeyboardButtonTapped, .passwordTapped:
      self = .changeFocus(.passwordTextField)
    case let .emailFieldChanged(email):
      self = .emailChanged(email)
    case .emailTapped:
      self = .changeFocus(.emailTextField)
    case .forgotPasswordTapped:
      self = .handleForgotPasswordTransition
    case .passwordEnterKeyboardButtonTapped, .signInTapped:
      self = .tryToSignIn
    case let .passwordFieldChanged(password):
      self = .passwordChanged(password)
    case .signUpTapped:
      self = .handleSignUpTransition
    case .tappedOutsideFocusedTextField:
      self = .changeFocus(.dismissFocus)
    }
  }
}

#if DEBUG
struct SignInView_Previews: PreviewProvider {
  static var previews: some View {
    SignInView(
      store: Store<SignInState, SignInAction>(
        initialState: .initialState(isOnline: true),
        reducer: signInReducer,
        environment: SystemEnvironment<SignInEnvironment>.live(environment: SignIn.mock)
      )
    )
  }
}
#endif
