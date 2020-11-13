import ComposableArchitecture
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
  
  let store: Store<State, Action>
  
  public init(store: Store<State, Action>) { self.store = store }
  
  public var body: some View {
    WithViewStore(store) { viewStore in
      VStack {
        Title(title: "Sign in to your account")
        TextFieldBlock(
          text: viewStore.binding(
            get: \.email,
            send: Action.emailChanged
          ),
          name: "Email address",
          errorText: "",
          focused: viewStore.fieldInFocus == .email,
          textContentType: .emailAddress,
          keyboardType: .emailAddress,
          returnKeyType: .next,
          wantsToBecomeFocused: { viewStore.send(.emailTapped) },
          enterButtonPressed: { viewStore.send(.emailEnterKeyboardButtonTapped) }
        )
        .disabled(viewStore.signingIn)
        .padding(.top, 50)
        .padding([.trailing, .leading], 16)
        TextFieldBlock(
          text: viewStore.binding(
            get: \.password,
            send: Action.passwordChanged
          ),
          name: "Password",
          errorText: viewStore.errorMessage,
          focused: viewStore.fieldInFocus == .password,
          textContentType: .password,
          secure: true,
          keyboardType: .default,
          returnKeyType: .send,
          enablesReturnKeyAutomatically: false,
          wantsToBecomeFocused: { viewStore.send(.passwordTapped) },
          enterButtonPressed: { viewStore.send(.passwordEnterKeyboardButtonTapped) }
        )
        .disabled(viewStore.signingIn)
        .padding(.top, 17)
        .padding([.trailing, .leading], 16)
        switch viewStore.buttonState {
        case .normal:
          PrimaryButton(
            variant: .normal(title: "Sign in")
          ) {
            viewStore.send(.signInTapped)
          }
          .padding(.top, 39)
          .padding([.trailing, .leading], 58)
        case .destructive:
          PrimaryButton(
            variant: .destructive(),
            showActivityIndicator: viewStore.signingIn) {
            viewStore.send(.cancelSignInTapped)
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
      }
      .modifier(AppBackground())
      .edgesIgnoringSafeArea(.all)
      .onTapGesture {
        if .none != viewStore.fieldInFocus {
          viewStore.send(.tappedOutsideFocus)
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
      store: .init(
        initialState: .init(
          buttonState: .destructive,
          email: "email@example.com",
          errorMessage: "Network error, please try again.",
          fieldInFocus: .none,
          password: "blablabla",
          signingIn: true
        ),
        reducer: .empty,
        environment: ()
      )
    )
  }
}
