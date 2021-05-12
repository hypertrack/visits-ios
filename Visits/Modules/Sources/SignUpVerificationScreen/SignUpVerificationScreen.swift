import SwiftUI
import Types
import Views

public struct SignUpVerificationScreen: View {
  private enum Focus { case none, first, second, third, fourth, fifth, sixth }
  
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
  
  let state: SignUpState.Verification.Status
  let send: (Action) -> Void
  @Environment(\.colorScheme) var colorScheme
  
  public init(
    state: SignUpState.Verification.Status,
    send: @escaping (Action) -> Void
  ) {
    self.state = state
    self.send = send
  }
  
  var firstField: String {
    switch state {
    case let .entered(ed):
      return String(ed.verificationCode.first.rawValue)
    case let .entering(eg):
      switch eg.codeEntry {
      case let .some(.one(d)),
           let .some(.two(d, _)),
           let .some(.three(d, _, _)),
           let .some(.four(d, _, _, _)),
           let .some(.five(d, _, _, _, _)):
        return String(d.rawValue)
      default:
        return ""
      }
    }
  }
  
  var secondField: String {
    switch state {
    case let .entered(ed):
      return String(ed.verificationCode.second.rawValue)
    case let .entering(eg):
      switch eg.codeEntry {
      case let .some(.two(_, d)),
           let .some(.three(_, d, _)),
           let .some(.four(_, d, _, _)),
           let .some(.five(_, d, _, _, _)):
        return String(d.rawValue)
      default:
        return ""
      }
    }
  }
  
  var thirdField: String {
    switch state {
    case let .entered(ed):
      return String(ed.verificationCode.third.rawValue)
    case let .entering(eg):
      switch eg.codeEntry {
      case let .some(.three(_, _, d)),
           let .some(.four(_, _, d, _)),
           let .some(.five(_, _, d, _, _)):
        return String(d.rawValue)
      default:
        return ""
      }
    }
  }
  
  var fourthField: String {
    switch state {
    case let .entered(ed):
      return String(ed.verificationCode.fourth.rawValue)
    case let .entering(eg):
      switch eg.codeEntry {
      case let .some(.four(_, _, _, d)),
           let .some(.five(_, _, _, d, _)):
        return String(d.rawValue)
      default:
        return ""
      }
    }
  }
  
  var fifthField: String {
    switch state {
    case let .entered(ed):
      return String(ed.verificationCode.fifth.rawValue)
    case let .entering(eg):
      switch eg.codeEntry {
      case let .some(.five(_, _, _, _, d)):
        return String(d.rawValue)
      default:
        return ""
      }
    }
  }
  
  var sixthField: String {
    switch state {
    case let .entered(ed):
      return String(ed.verificationCode.sixth.rawValue)
    default:
      return ""
    }
  }
  
  private var fieldInFocus: Focus {
    switch state {
    case let .entering(eg):
      switch (eg.codeEntry, eg.focus) {
      case (.none,  .focused):   return .first
      case (.one,   .focused):   return .second
      case (.two,   .focused):   return .third
      case (.three, .focused):   return .fourth
      case (.four,  .focused):   return .fifth
      case (.five,  .focused):   return .sixth
      case (_,      .unfocused): return .none
      }
    case .entered:               return .none
    }
  }
  
  var verifying: Bool {
    switch state {
    case .entered:  return true
    case let .entering(eg):
      if eg.request != nil {
        return true
      } else {
        return false
      }
    }
  }
  
  var error: String {
    switch state {
    case let .entering(eg): return eg.error?.string ?? ""
    case .entered:          return ""
    }
  }
  
  public var body: some View {
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
          code: firstField,
          codeChanged: { send(.firstFieldChanged($0)) },
          inFocus: fieldInFocus == .first,
          tapped: { send(.fieldsTapped) },
          backspacePressed: { send(.backspacePressed) }
        )
        CodeDigitView(
          tag: "Second Digit",
          code: secondField,
          codeChanged: { send(.secondFieldChanged($0)) },
          inFocus: fieldInFocus == .second,
          tapped: { send(.fieldsTapped) },
          backspacePressed: { send(.backspacePressed) }
        )
        CodeDigitView(
          tag: "Third Digit",
          code: thirdField,
          codeChanged: { send(.thirdFieldChanged($0)) },
          inFocus: fieldInFocus == .third,
          tapped: { send(.fieldsTapped) },
          backspacePressed: { send(.backspacePressed) }
        )
        .padding(.trailing, 8)
        CodeDigitView(
          tag: "Fourth Digit",
          code: fourthField,
          codeChanged: { send(.fourthFieldChanged($0)) },
          inFocus: fieldInFocus == .fourth,
          tapped: { send(.fieldsTapped) },
          backspacePressed: { send(.backspacePressed) }
        )
        CodeDigitView(
          tag: "Fifth Digit",
          code: fifthField,
          codeChanged: { send(.fifthFieldChanged($0)) },
          inFocus: fieldInFocus == .fifth,
          tapped: { send(.fieldsTapped) },
          backspacePressed: { send(.backspacePressed) }
        )
        CodeDigitView(
          tag: "Sixth Digit",
          code: sixthField,
          codeChanged: { send(.sixthFieldChanged($0)) },
          inFocus: fieldInFocus == .sixth,
          tapped: { send(.fieldsTapped) },
          backspacePressed: { send(.backspacePressed) }
        )
      }
      if !error.isEmpty {
        Text(error)
          .lineLimit(3)
          .font(.smallMedium)
          .foregroundColor(.radicalRed)
          .padding(.horizontal)
      }
      
      if #available(iOS 14.0, *) {
        if verifying {
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
      .padding(.bottom, 30)
    }
    .appBackground()
    .edgesIgnoringSafeArea(.all)
    .onTapGesture {
      send(.tappedOutsideFocus)
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
      state: .entering(.init(codeEntry: .five(.four, .eight, .seven, .one, .five), focus: .focused)),
      send: { _ in }
    )
    .previewScheme(.dark)
  }
}
