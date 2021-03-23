import SwiftUI
import Views


public struct SignInScreen: View {
  public struct State {
    let buttonState: ButtonState
    let email: String
    let errorMessage: String
    let fieldInFocus: Focus
    let password: String
    let signingIn: Bool
    
    public enum Focus { case email, password, none }
    public enum ButtonState { case normal, destructive, disabled }
    
    public init(
      buttonState: ButtonState,
      email: String,
      errorMessage: String,
      fieldInFocus: Focus,
      password: String,
      signingIn: Bool
    ) {
      self.buttonState = buttonState
      self.email = email
      self.errorMessage = errorMessage
      self.fieldInFocus = fieldInFocus
      self.password = password
      self.signingIn = signingIn
    }
  }
  public enum Action {
    case signUpTapped
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
  
  let state: State
  let send: (Action) -> Void
  
  public init(
    state: State,
    send: @escaping (Action) -> Void
  ) {
    self.state = state
    self.send = send
  }
  
  public var body: some View {
    GeometryReader { geometry in
      VStack {
        Title(title: "Sign in to your account")
        TextFieldBlock(
          text: Binding(
            get: { state.email },
            set: { send(.emailChanged($0)) }
          ),
          name: "Email address",
          errorText: "",
          focused: state.fieldInFocus == .email,
          textContentType: .emailAddress,
          keyboardType: .emailAddress,
          returnKeyType: .next,
          wantsToBecomeFocused: { send(.emailTapped) },
          enterButtonPressed: { send(.emailEnterKeyboardButtonTapped) }
        )
        .disabled(state.signingIn)
        .padding(.top, 50)
        .padding([.trailing, .leading], 16)
        TextFieldBlock(
          text: Binding(
            get: { state.password },
            set: { send(.passwordChanged($0)) }
          ),
          name: "Password",
          errorText: state.errorMessage,
          focused: state.fieldInFocus == .password,
          textContentType: .password,
          secure: true,
          keyboardType: .default,
          returnKeyType: .send,
          enablesReturnKeyAutomatically: false,
          wantsToBecomeFocused: { send(.passwordTapped) },
          enterButtonPressed: { send(.passwordEnterKeyboardButtonTapped) }
        )
        .disabled(state.signingIn)
        .padding(.top, 17)
        .padding([.trailing, .leading], 16)
        switch state.buttonState {
        case .normal:
          PrimaryButton(
            variant: .normal(title: "Sign in")
          ) {
            send(.signInTapped)
          }
          .padding(.top, 39)
          .padding([.trailing, .leading], 58)
        case .destructive:
          PrimaryButton(
            variant: .destructive(),
            showActivityIndicator: state.signingIn) {
            send(.cancelSignInTapped)
          }
          .padding(.top, 39)
          .padding([.trailing, .leading], 58)
        case .disabled:
          PrimaryButton(
            variant: .disabled(title: "Sign in")
          ) {}
          .disabled(true)
          .padding(.top, 39)
          .padding([.trailing, .leading], 58)
        }
        Spacer()
        Text("Don’t have an account?")
          .font(
            Font.system(size: 14)
              .weight(.medium))
          .foregroundColor(.ghost)
        TransparentButton(title: "Sign up?") {
          send(.signUpTapped)
        }
        .padding(.top, 12)
        .padding([.trailing, .leading], 58)
        .padding(
          .bottom,
          geometry.safeAreaInsets.bottom > 0 ? geometry.safeAreaInsets
            .bottom : 24
        )
      }
      .modifier(AppBackground())
      .edgesIgnoringSafeArea(.all)
      .ignoreKeyboard()
      .onTapGesture {
        if .none != state.fieldInFocus {
          send(.tappedOutsideFocus)
        }
      }
    }
  }
}

extension SignInScreen.State: Equatable {}
extension SignInScreen.State.Focus: Equatable {}
extension SignInScreen.State.ButtonState: Equatable {}
extension SignInScreen.Action: Equatable {}

struct SignInScreen_Previews: PreviewProvider {
  static var previews: some View {
    SignInScreen(
      state: .init(
        buttonState: .normal,
        email: "help@hypertrack.com",
        errorMessage: "",
        fieldInFocus: .none,
        password: "StrongPassword",
        signingIn: false
      ),
      send: { _ in }
    )
    .previewScheme(.dark)
//    .previewDevice("iPhone SE (1st generation)")
  }
}