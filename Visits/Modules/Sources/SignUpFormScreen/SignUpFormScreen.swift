import SwiftUI
import Views

public struct SignUpFormScreen: View {
  public struct State: Equatable {
    let name: String
    let email: String
    let password: String
    let fieldInFocus: Focus
    let formIsValid: Bool
    let questionsAnswered: Bool
    let errorMessage: String
    
    public enum Focus { case name, email, password, none }
    
    public init(
      name: String,
      email: String,
      password: String,
      fieldInFocus: Focus,
      formIsValid: Bool,
      questionsAnswered: Bool,
      errorMessage: String
    ) {
      self.name = name
      self.email = email
      self.password = password
      self.fieldInFocus = fieldInFocus
      self.formIsValid = formIsValid
      self.questionsAnswered = questionsAnswered
      self.errorMessage = errorMessage
    }
  }
  
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
  
  let state: State
  let send: (Action) -> Void
  @Environment(\.colorScheme) var colorScheme
  
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
        Title(title: "Sign up for a new account")
        Text("Free 100k events per month. No credit card required.")
          .multilineTextAlignment(.center)
          .font(.smallMedium)
          .foregroundColor(colorScheme == .dark ? .ghost : .greySuit)
        HStack {
          Rectangle()
            .frame(width: 24, height: 8)
            .foregroundColor(state.formIsValid ? Color.dodgerBlue : .ghost)
            .cornerRadius(4)
          Rectangle()
            .frame(width: 8, height: 8)
            .foregroundColor(state.questionsAnswered ? Color.dodgerBlue : .ghost)
            .cornerRadius(4)
        }
        TextFieldBlock(
          text: Binding(
            get: { state.name },
            set: { send(.nameChanged($0)) }
          ),
          name: "Business name",
          errorText: "",
          focused: state.fieldInFocus == .name,
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
            get: { state.email },
            set: { send(.emailChanged($0)) }
          ),
          name: "Business email",
          errorText: "",
          focused: state.fieldInFocus == .email,
          textContentType: .emailAddress,
          keyboardType: .emailAddress,
          returnKeyType: .next,
          wantsToBecomeFocused: { send(.emailTapped) },
          enterButtonPressed: { send(.emailEnterKeyboardButtonTapped) }
        )
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
        send(.tappedOutsideFocus)
      }
    }
  }
}


struct SignUpFormScreen_Previews: PreviewProvider {
  static var previews: some View {
    SignUpFormScreen(
      state: .init(
        name: "HyperTrack",
        email: "help@hypertrack.com",
        password: "StrongPassword!@#$",
        fieldInFocus: .none,
        formIsValid: false,
        questionsAnswered: false,
        errorMessage: ""
      ),
      send: {_ in }
    )
    .previewScheme(.dark)
  }
}
