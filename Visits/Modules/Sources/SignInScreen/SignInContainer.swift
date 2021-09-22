import SwiftUI
import Types
import Views


struct SignInContainer<Content: View>: View {
  let state: SignInState
  let send: (SignInScreenAction) -> Void
  private let content: () -> Content

  init(
    state: SignInState,
    send: @escaping (SignInScreenAction) -> Void,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.state = state
    self.send = send
    self.content = content
  }

  var body: some View {
    VStack {
      Title(title: "Sign in to your account")
      content()
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
          variant: .disabled(title: "Sign in"),
          showActivityIndicator: state.signingIn
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
      if .none != state.fieldInFocus {
        send(.tappedOutsideFocus)
      }
    }
  }
}
