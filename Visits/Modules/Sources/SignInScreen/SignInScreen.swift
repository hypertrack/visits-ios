import SwiftUI
import Types
import Views


@available(iOS 15.0, *)
public struct SignInScreen: View {

  let state: SignInState
  let send: (SignInScreenAction) -> Void

  public init(
    state: SignInState,
    send: @escaping (SignInScreenAction) -> Void
  ) {
    self.state = state
    self.send = send
  }

  @FocusState private var swiftUIFocused: SignInState.Entering.Focus?

  public var body: some View {
    SignInContainer(state: state, send: send) {
      EmailField(
        email: state.email,
        focused: state.fieldInFocus == .email,
        signingIn: state.signingIn,
        send: lift(to: send)
      )
        .focused($swiftUIFocused, equals: .email)
      PasswordField(
        password: state.password,
        errorMessage: state.errorMessage,
        focused: state.fieldInFocus == .password,
        signingIn: state.signingIn,
        send: lift(to: send)
      )
        .focused($swiftUIFocused, equals: .password)
    }
    .synchronize(
      .init(
        get: { state.fieldInFocus },
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


// MARK: - Previews

struct SignInScreen_Previews: PreviewProvider {
  static var previews: some View {
    if #available(iOS 15.0, *) {
      SignInScreen(state: previewState, send: { _ in })
        .previewScheme(.dark)
    } else {
      SignInScreeniOS14(state: previewState, send: { _ in })
        .previewScheme(.dark)
    }
  }
}

private let previewState: SignInState = .entered(
  .init(email: "help@hypertrack.com", password: "StrongPassword", request: .success("sadf"))
)
