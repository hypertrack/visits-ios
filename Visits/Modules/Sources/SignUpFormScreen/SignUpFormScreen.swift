import SwiftUI
import Types
import Views

public struct SignUpFormScreen: View {
  private enum Focus { case name, email, password, none }
  
  public enum Action: Equatable {
    case nameTapped
    case nameChanged(String)
    case nameEnterKeyboardButtonTapped
    case emailTapped
    case emailChanged(String)
    case emailEnterKeyboardButtonTapped
    case passwordTapped
    case passwordChanged(String)
    case passwordEnterKeyboardButtonTapped
    case nextButtonTapped
    case signInTapped
    case tappedOutsideFocus
  }
  
  let state: SignUpState.Form
  let send: (Action) -> Void
  @Environment(\.colorScheme) var colorScheme
  
  public init(
    state: SignUpState.Form,
    send: @escaping (Action) -> Void
  ) {
    self.state = state
    self.send = send
  }
  
  var name: String {
    switch state.status {
    case let .filling(fg): return fg.businessName?.string ?? ""
    case let .filled(fd):  return fd.businessName.string
    }
  }
  
  var email: String {
    switch state.status {
    case let .filling(fg): return fg.email?.string ?? ""
    case let .filled(fd):  return fd.email.string
    }
  }
  
  var password: String {
    switch state.status {
    case let .filling(fg): return fg.password?.string ?? ""
    case let .filled(fd):  return fd.password.string
    }
  }
  
  private var fieldInFocus: Focus {
    switch state.focus {
    case .name:     return .name
    case .email:    return .email
    case .password: return .password
    case .none:     return .none
    }
  }
  
  var formIsValid: Bool {
    switch state.status {
    case let .filling(fg):
      switch (fg.businessName, fg.email, fg.password) {
      case let (.some, .some(e), .some(p)) where e.isValid() && p.isValid():
        return true
      default:
        return false
      }
    case .filled: return true
    }
  }
  
  var questionsAnswered: Bool = false
  
  var errorMessage: String {
    state.error?.string ?? ""
  }
  
  public var body: some View {
    VStack {
      Title(title: "Sign up for a new account")
      Text("Free 100k events per month. No credit card required.")
        .multilineTextAlignment(.center)
        .font(.smallMedium)
        .foregroundColor(colorScheme == .dark ? .ghost : .greySuit)
      HStack {
        Rectangle()
          .frame(width: 24, height: 8)
          .foregroundColor(formIsValid ? Color.dodgerBlue : .ghost)
          .cornerRadius(4)
        Rectangle()
          .frame(width: 8, height: 8)
          .foregroundColor(questionsAnswered ? Color.dodgerBlue : .ghost)
          .cornerRadius(4)
      }
      TextFieldBlock(
        text: Binding(
          get: { name },
          set: { send(.nameChanged($0)) }
        ),
        name: "Business name",
        errorText: "",
        focused: fieldInFocus == .name,
        textContentType: .organizationName,
        keyboardType: .alphabet,
        returnKeyType: .next,
        wantsToBecomeFocused: { send(.nameTapped) },
        enterButtonPressed: { send(.nameEnterKeyboardButtonTapped) }
      )
      .disabled(false)
      .padding([.trailing, .leading], 16)
      TextFieldBlock(
        text: Binding(
          get: { email },
          set: { send(.emailChanged($0)) }
        ),
        name: "Business email",
        errorText: "",
        focused: fieldInFocus == .email,
        textContentType: .emailAddress,
        keyboardType: .emailAddress,
        returnKeyType: .next,
        wantsToBecomeFocused: { send(.emailTapped) },
        enterButtonPressed: { send(.emailEnterKeyboardButtonTapped) }
      )
      .padding([.trailing, .leading], 16)
      TextFieldBlock(
        text: Binding(
          get: { password },
          set: { send(.passwordChanged($0)) }
        ),
        name: "Password",
        errorText: errorMessage,
        focused: fieldInFocus == .password,
        textContentType: .password,
        secure: true,
        keyboardType: .default,
        returnKeyType: .send,
        enablesReturnKeyAutomatically: false,
        wantsToBecomeFocused: { send(.passwordTapped) },
        enterButtonPressed: { send(.passwordEnterKeyboardButtonTapped) }
      )
      .padding([.trailing, .leading], 16)
      PrimaryButton(variant: .normal(title: "Next")) {
        send(.nextButtonTapped)
      }
      .padding([.leading, .trailing], 44)
      Spacer()
      Text("Already have an account?")
        .font(
          Font.system(size: 14)
            .weight(.medium))
        .foregroundColor(.ghost)
      TransparentButton(title: "Sign in") {
        send(.signInTapped)
      }
      .padding(.top, 12)
      .padding([.trailing, .leading], 58)
      .padding(.bottom, 30)
    }
    .modifier(AppBackground())
    .edgesIgnoringSafeArea(.all)
    .onTapGesture {
      send(.tappedOutsideFocus)
    }
  }
}


struct SignUpFormScreen_Previews: PreviewProvider {
  static var previews: some View {
    SignUpFormScreen(
      state: .init(status: .filled(.init(businessName: "HyperTrack", email: "help@hypertrack.com", password: "StrongPassword!@#$"))),
      send: {_ in }
    )
    .previewScheme(.dark)
  }
}
