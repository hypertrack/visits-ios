import SwiftUI
import Views


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
