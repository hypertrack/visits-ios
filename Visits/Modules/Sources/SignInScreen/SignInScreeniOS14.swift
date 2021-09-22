import SwiftUI
import Types


public struct SignInScreeniOS14: View {
  let state: SignInState
  let send: (SignInScreenAction) -> Void

  public init(
    state: SignInState,
    send: @escaping (SignInScreenAction) -> Void
  ) {
    self.state = state
    self.send = send
  }

  public var body: some View {
    SignInContainer(state: state, send: send) {
      EmailField(
        email: state.email,
        focused: state.fieldInFocus == .email,
        signingIn: state.signingIn,
        send: lift(to: send)
      )
      PasswordField(
        password: state.password,
        errorMessage: state.errorMessage,
        focused: state.fieldInFocus == .password,
        signingIn: state.signingIn,
        send: lift(to: send)
      )
    }
  }
}
