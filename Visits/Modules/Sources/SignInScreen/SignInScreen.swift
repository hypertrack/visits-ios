import SwiftUI
import Types
import Views


public struct SignInScreen: View {
  public enum ButtonState { case normal, destructive, disabled }
  
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
  
  let state: SignInState
  let send: (Action) -> Void

  public init(
    state: SignInState,
    send: @escaping (Action) -> Void
  ) {
    self.state = state
    self.send = send
  }
  
  var buttonState: ButtonState {
    switch state {
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
    switch state {
    case let .entering(eg): return eg.email?.string ?? ""
    case let .entered(ed):  return ed.email.string
    }
  }
  
  var errorMessage: String {
    switch state {
    case let .entering(eg): return eg.error?.string ?? ""
    case .entered:          return ""
    }
  }

  @available(iOS 15.0, *)
  @FocusState private var swiftUIFocused: SignInState.Entering.Focus?

  var fieldInFocus: SignInState.Entering.Focus? {
    switch state {
    case let .entering(eg):
      switch eg.focus {
      case .none:            return .none
      case .some(.email):    return .email
      case .some(.password): return .password
      }
    case .entered:           return .none
    }
  }
  
  var password: String {
    switch state {
    case let .entering(eg): return eg.password?.string ?? ""
    case let .entered(ed):  return ed.password.string
    }
  }
  
  var signingIn: Bool {
    switch state {
    case .entering: return false
    case .entered:  return true
    }
  }
  
  public var body: some View {
    VStack {
      Title(title: "Sign in to your account")
      if #available(iOS 15.0, *) {
        Group {
          EmailField(
            email: email,
            focused: fieldInFocus == .email,
            signingIn: signingIn,
            send: {
              switch $0 {
              case let .emailChanged(e):                send(.emailChanged(e))
              case     .emailEnterKeyboardButtonTapped: send(.emailEnterKeyboardButtonTapped)
              case     .emailTapped:                    send(.emailTapped)
              }
            }
          )
            .focused($swiftUIFocused, equals: .email)
          PasswordField(
            password: password,
            errorMessage: errorMessage,
            focused: fieldInFocus == .password,
            signingIn: signingIn,
            send: {
              switch $0 {
              case let .passwordChanged(p):                send(.passwordChanged(p))
              case     .passwordEnterKeyboardButtonTapped: send(.passwordEnterKeyboardButtonTapped)
              case     .passwordTapped:                    send(.passwordTapped)
              }
            }
          )
            .focused($swiftUIFocused, equals: .password)
        }
        .synchronize(
          .init(
            get: { fieldInFocus },
            set: { focus, _ in
              switch focus {
              case .none: send(.tappedOutsideFocus)
              case .password: send(.passwordTapped)
              case .email: send(.emailTapped)
              }
            }
          ),
          $swiftUIFocused
        )
      } else {
        EmailField(
          email: email,
          focused: fieldInFocus == .email,
          signingIn: signingIn,
          send: {
            switch $0 {
            case let .emailChanged(e):                send(.emailChanged(e))
            case     .emailEnterKeyboardButtonTapped: send(.emailEnterKeyboardButtonTapped)
            case     .emailTapped:                    send(.emailTapped)
            }
          }
        )
        PasswordField(
          password: password,
          errorMessage: errorMessage,
          focused: fieldInFocus == .password,
          signingIn: signingIn,
          send: {
            switch $0 {
            case let .passwordChanged(p):                send(.passwordChanged(p))
            case     .passwordEnterKeyboardButtonTapped: send(.passwordEnterKeyboardButtonTapped)
            case     .passwordTapped:                    send(.passwordTapped)
            }
          }
        )
      }
      switch buttonState {
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
          showActivityIndicator: signingIn) {
          send(.cancelSignInTapped)
        }
        .padding(.top, 39)
        .padding([.trailing, .leading], 58)
      case .disabled:
        PrimaryButton(
          variant: .disabled(title: "Sign in"),
          showActivityIndicator: signingIn
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
      if .none != fieldInFocus {
        send(.tappedOutsideFocus)
      }
    }
  }
}

struct EmailField: View {
  enum Action {
    case emailChanged(String)
    case emailEnterKeyboardButtonTapped
    case emailTapped
  }

  let email: String
  let focused: Bool
  let signingIn: Bool

  let send: (Action) -> Void

  var body: some View {
    TextFieldBlock(
      text: Binding(
        get: { email },
        set: { send(.emailChanged($0)) }
      ),
      name: "Email address",
      errorText: "",
      focused: focused,
      textContentType: .emailAddress,
      keyboardType: .emailAddress,
      returnKeyType: .next,
      wantsToBecomeFocused: { send(.emailTapped) },
      enterButtonPressed: { send(.emailEnterKeyboardButtonTapped) }
    )
    .disabled(signingIn)
    .padding(.top, 50)
    .padding([.trailing, .leading], 16)
  }
}

struct PasswordField: View {
  enum Action {
    case passwordChanged(String)
    case passwordEnterKeyboardButtonTapped
    case passwordTapped
  }

  let password: String
  let errorMessage: String
  let focused: Bool
  let signingIn: Bool

  let send: (Action) -> Void

  var body: some View {
    TextFieldBlock(
      text: Binding(
        get: { password },
        set: { send(.passwordChanged($0)) }
      ),
      name: "Password",
      errorText: errorMessage,
      focused: focused,
      textContentType: .password,
      secure: true,
      keyboardType: .default,
      returnKeyType: .send,
      enablesReturnKeyAutomatically: false,
      wantsToBecomeFocused: { send(.passwordTapped) },
      enterButtonPressed: { send(.passwordEnterKeyboardButtonTapped) }
    )
    .disabled(signingIn)
    .padding(.top, 17)
    .padding([.trailing, .leading], 16)
  }
}

@available(iOS 15.0, *)
private extension View {
   func synchronize<Value: Equatable>(
     _ first: Binding<Value>,
     _ second: FocusState<Value>.Binding
   ) -> some View {
     self
       .onChange(of: first.wrappedValue) { second.wrappedValue = $0 }
       .onChange(of: second.wrappedValue) { first.wrappedValue = $0 }
   }
 }

extension SignInScreen.ButtonState: Equatable {}
extension SignInScreen.Action: Equatable {}

struct SignInScreen_Previews: PreviewProvider {
  static var previews: some View {
    SignInScreen(
      state: .entered(
        .init(email: "help@hypertrack.com", password: "StrongPassword", request: .success("sadf"))
      ),
      send: { _ in }
    )
    .previewScheme(.dark)
//    .previewDevice("iPhone SE (1st generation)")
  }
}
