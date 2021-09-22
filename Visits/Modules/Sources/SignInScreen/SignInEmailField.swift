import SwiftUI
import Views


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
