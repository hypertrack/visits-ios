import SwiftUI
import Views

public struct SignUpVerificationScreen: View {
  public struct State: Equatable {
    let firstField: String
    let secondField: String
    let thirdField: String
    let fourthField: String
    let fifthField: String
    let sixthField: String
    let fieldInFocus: Focus
    let verifying: Bool
    let error: String
    
    public enum Focus { case none, first, second, third, fourth, fifth, sixth }
    
    public init(
      firstField: String,
      secondField: String,
      thirdField: String,
      fourthField: String,
      fifthField: String,
      sixthField: String,
      fieldInFocus: SignUpVerificationScreen.State.Focus,
      verifying: Bool,
      error: String
    ) {
      self.firstField = firstField
      self.secondField = secondField
      self.thirdField = thirdField
      self.fourthField = fourthField
      self.fifthField = fifthField
      self.sixthField = sixthField
      self.fieldInFocus = fieldInFocus
      self.verifying = verifying
      self.error = error
    }
  }
  
  public enum Action: Equatable {
    case firstFieldChanged(String)
    case secondFieldChanged(String)
    case thirdFieldChanged(String)
    case fourthFieldChanged(String)
    case fifthFieldChanged(String)
    case sixthFieldChanged(String)
    case backspacePressed
    case fieldsTapped
    case tappedOutsideFocus
    case resendButtonTapped
    case signInTapped
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
        Title(title: "Verify your email", withCheck: true)
        Text("We have sent you an email with the confirmation code. Please enter the code in the email to continue.")
          .multilineTextAlignment(.center)
          .font(.smallMedium)
          .foregroundColor(colorScheme == .dark ? .ghost : .greySuit)
          .padding(.horizontal, 6)
          .padding(.bottom, 20)
        Spacer()
        HStack {
          CodeDigitView(
            tag: "First Digit",
            code: state.firstField,
            codeChanged: { send(.firstFieldChanged($0)) },
            inFocus: state.fieldInFocus == .first,
            tapped: { send(.fieldsTapped) },
            backspacePressed: { send(.backspacePressed) }
          )
          CodeDigitView(
            tag: "Second Digit",
            code: state.secondField,
            codeChanged: { send(.secondFieldChanged($0)) },
            inFocus: state.fieldInFocus == .second,
            tapped: { send(.fieldsTapped) },
            backspacePressed: { send(.backspacePressed) }
          )
          CodeDigitView(
            tag: "Third Digit",
            code: state.thirdField,
            codeChanged: { send(.thirdFieldChanged($0)) },
            inFocus: state.fieldInFocus == .third,
            tapped: { send(.fieldsTapped) },
            backspacePressed: { send(.backspacePressed) }
          )
          .padding(.trailing, 8)
          CodeDigitView(
            tag: "Fourth Digit",
            code: state.fourthField,
            codeChanged: { send(.fourthFieldChanged($0)) },
            inFocus: state.fieldInFocus == .fourth,
            tapped: { send(.fieldsTapped) },
            backspacePressed: { send(.backspacePressed) }
          )
          CodeDigitView(
            tag: "Fifth Digit",
            code: state.fifthField,
            codeChanged: { send(.fifthFieldChanged($0)) },
            inFocus: state.fieldInFocus == .fifth,
            tapped: { send(.fieldsTapped) },
            backspacePressed: { send(.backspacePressed) }
          )
          CodeDigitView(
            tag: "Sixth Digit",
            code: state.sixthField,
            codeChanged: { send(.sixthFieldChanged($0)) },
            inFocus: state.fieldInFocus == .sixth,
            tapped: { send(.fieldsTapped) },
            backspacePressed: { send(.backspacePressed) }
          )
        }
        if !state.error.isEmpty {
          Text(state.error)
            .lineLimit(3)
            .font(.smallMedium)
            .foregroundColor(.radicalRed)
            .padding(.horizontal)
        }
        
        if #available(iOS 14.0, *) {
          if state.verifying {
            ProgressView()
          }
        }
        
        LinkButton(title: "Resend verification code") {
          send(.resendButtonTapped)
        }
        .padding(.bottom, 100)
        Spacer()
        Text("Already verified?")
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
      .appBackground()
      .edgesIgnoringSafeArea(.all)
      .ignoreKeyboard()
      .onTapGesture {
        send(.tappedOutsideFocus)
      }
    }
  }
}

struct CodeDigitView: View {
  let tag: String
  let code: String
  let codeChanged: (String) -> Void
  let inFocus: Bool
  let tapped: () -> Void
  let backspacePressed: () -> Void
  @Environment(\.colorScheme) var colorScheme
  
  var body: some View {
    CustomTextField(
      text: Binding(
        get: { code },
        set: { codeChanged($0) }
      ),
      focused: inFocus,
      blocksFocus: true,
      textContentType: .oneTimeCode,
      keyboardType: .numberPad,
      returnKeyType: .next,
      enablesReturnKeyAutomatically: true,
      isSecureTextEntry: false,
      textAlignment: .center,
      wantsToBecomeFocused: tapped,
      enterButtonPressed: {},
      backspacePressed: backspacePressed
    )
    .accentColor(.blue)
    .frame(width: 40, height: 40, alignment: .center)
    .overlay(
      RoundedRectangle(cornerRadius: 5)
        .stroke(inFocus ? Color.blue : colorScheme == .dark ? Color.ghost : .greySuit, lineWidth: 2)
        .animation(.default)
    )
  }
}

struct SignUpVerificationScreen_Previews: PreviewProvider {
  static var previews: some View {
    SignUpVerificationScreen(
      state: .init(
        firstField: "9",
        secondField: "2",
        thirdField: "4",
        fourthField: "5",
        fifthField: "1",
        sixthField: "2",
        fieldInFocus: .none,
        verifying: false,
        error: ""
      ),
      send: { _ in }
    )
    .previewScheme(.dark)
  }
}
