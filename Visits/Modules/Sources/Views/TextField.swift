import SwiftUI

// MARK: - PrimaryTextField

public struct TextFieldBlock: View {
  public enum NameStyle { case dimmed, pronounced }

  @Binding private var text: String
  private let name: String
  private let errorText: String
  private let focused: Bool
  private let nameStyle: NameStyle
  private let textContentType: UITextContentType
  private let secure: Bool
  private let keyboardType: UIKeyboardType
  private let returnKeyType: UIReturnKeyType
  private let enablesReturnKeyAutomatically: Bool
  private let wantsToBecomeFocused: () -> Void
  private let enterButtonPressed: () -> Void
  @Environment(\.colorScheme) var colorScheme
  
  public init(
    text: Binding<String>,
    name: String,
    errorText: String,
    focused: Bool,
    textContentType: UITextContentType,
    nameStyle: NameStyle = .dimmed,
    secure: Bool = false,
    keyboardType: UIKeyboardType = UIKeyboardType.default,
    returnKeyType: UIReturnKeyType = UIReturnKeyType.default,
    enablesReturnKeyAutomatically: Bool = false,
    wantsToBecomeFocused: @escaping () -> Void = {},
    enterButtonPressed: @escaping () -> Void = {}
  ) {
    self._text = text
    self.name = name
    self.errorText = errorText
    self.focused = focused
    self.nameStyle = nameStyle
    self.textContentType = textContentType
    self.secure = secure
    self.keyboardType = keyboardType
    self.returnKeyType = returnKeyType
    self.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
    self.wantsToBecomeFocused = wantsToBecomeFocused
    self.enterButtonPressed = enterButtonPressed
  }
  
  public var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      
      switch nameStyle {
      case .dimmed:
        Text(name)
          .font(.smallMedium)
          .foregroundColor(.greySuit)
      case .pronounced:
        Text(name)
          .font(.smallMedium)
          .foregroundColor(colorScheme == .dark ? .white : .gunPowder)
      }
      if #available(iOS 15.0, *) {
        if secure {
          SecureField(
            "",
            text: $text
          )
            .textContentType(textContentType)
            .keyboardType(keyboardType)
            .submitLabel(returnKeyTypeToLabel(returnKeyType))
            .onSubmit(enterButtonPressed)
        } else {
          TextField(
            "",
            text: $text
          )
            .textContentType(textContentType)
            .keyboardType(keyboardType)
            .submitLabel(returnKeyTypeToLabel(returnKeyType))
            .onSubmit(enterButtonPressed)
        }
      } else {
        CustomTextField(
          text: $text,
          focused: focused,
          textContentType: textContentType,
          keyboardType: keyboardType,
          returnKeyType: returnKeyType,
          enablesReturnKeyAutomatically: enablesReturnKeyAutomatically,
          isSecureTextEntry: secure,
          wantsToBecomeFocused: wantsToBecomeFocused,
          enterButtonPressed: enterButtonPressed
        )
        .frame(height: 29)
        .offset(y: 5)
      }
      Rectangle()
        .foregroundColor(.ghost)
        .frame(height: 1.0, alignment: .bottom)
        .padding(.top, 6)
      Text(errorText)
        .lineLimit(3)
        .font(.smallMedium)
        .foregroundColor(.radicalRed)
    }
    .contentShape(Rectangle())
    .onTapGesture { }
  }
}

@available(iOS 15.0, *)
func returnKeyTypeToLabel(_ returnKeyType: UIReturnKeyType) -> SubmitLabel {
  switch returnKeyType {
  case .default:       return .done
  case .go:            return .go
  case .google:        return .search
  case .join:          return .join
  case .next:          return .next
  case .route:         return .route
  case .search:        return .search
  case .send:          return .send
  case .yahoo:         return .search
  case .done:          return .done
  case .emergencyCall: return .next
  case .continue:      return .continue
  @unknown default:    return .done
  }
}

// MARK: - CustomTextField

public class FocusableTextField: UITextField {
  var customFocused: Bool = false
  var blocksFocus: Bool = false
  var whenDeletesBackward: () -> Void = {}
  
  override public func deleteBackward() {
    if text == "" {
      whenDeletesBackward()
    }
    super.deleteBackward()
  }
}

public struct CustomTextField: UIViewRepresentable {
  public init(
    text: Binding<String>,
    focused: Bool,
    blocksFocus: Bool = false,
    textContentType: UITextContentType?,
    keyboardType: UIKeyboardType,
    returnKeyType: UIReturnKeyType,
    enablesReturnKeyAutomatically: Bool,
    isSecureTextEntry: Bool,
    textAlignment: NSTextAlignment = .left,
    wantsToBecomeFocused: @escaping () -> Void,
    enterButtonPressed: @escaping () -> Void,
    backspacePressed: @escaping () -> Void = {}
  ) {
    self._text = text
    self.focused = focused
    self.blocksFocus = blocksFocus
    self.textContentType = textContentType
    self.keyboardType = keyboardType
    self.returnKeyType = returnKeyType
    self.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
    self.isSecureTextEntry = isSecureTextEntry
    self.textAlignment = textAlignment
    self.wantsToBecomeFocused = wantsToBecomeFocused
    self.enterButtonPressed = enterButtonPressed
    self.backspacePressed = backspacePressed
  }
  
  @Binding var text: String
  let focused: Bool
  let blocksFocus: Bool
  let textContentType: UITextContentType?
  let keyboardType: UIKeyboardType
  let returnKeyType: UIReturnKeyType
  let enablesReturnKeyAutomatically: Bool
  let isSecureTextEntry: Bool
  let textAlignment: NSTextAlignment
  let wantsToBecomeFocused: () -> Void
  let enterButtonPressed: () -> Void
  let backspacePressed: () -> Void
  
  public func makeUIView(context: Context) -> FocusableTextField {
    let textField = FocusableTextField(frame: .zero)
    textField.customFocused = focused
    textField.blocksFocus = blocksFocus
    textField.keyboardType = keyboardType
    textField.returnKeyType = returnKeyType
    textField.delegate = context.coordinator
    textField.isSecureTextEntry = isSecureTextEntry
    textField.autocorrectionType = .no
    textField.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
    textField.textContentType = textContentType
    textField.textAlignment = textAlignment
    textField.whenDeletesBackward = backspacePressed
    return textField
  }
  
  public func updateUIView(_ textField: FocusableTextField, context: Context) {
    textField.customFocused = focused
    textField.text = text
    if focused {
      textField.becomeFirstResponder()
    } else {
      textField.resignFirstResponder()
    }
  }
  
  public func makeCoordinator() -> Coordinator { Coordinator(self) }
  
  public class Coordinator: NSObject, UITextFieldDelegate {
    var parent: CustomTextField
    
    init(_ textField: CustomTextField) { parent = textField }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
      let textField = textField as! FocusableTextField
      if !textField.customFocused { parent.wantsToBecomeFocused() }
      return textField.blocksFocus ? textField.customFocused : true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      parent.enterButtonPressed()
      return true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
      if let text = textField.text,
         let textRange = Range(range, in: text) {
        parent.text = text.replacingCharacters(in: textRange, with: string)
      }
      return false
    }
  }
}

struct TextFieldBlock_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      TextFieldBlock(
        text: .constant("email@example.com"),
        name: "Email",
        errorText: "Incorrect email",
        focused: false,
        textContentType: .emailAddress
      )
      .previewScheme(.light)
      TextFieldBlock(
        text: .constant("email@example.com"),
        name: "Email",
        errorText: "Incorrect email",
        focused: false,
        textContentType: .emailAddress
      )
      .previewScheme(.dark)
      TextFieldBlock(
        text: .constant("email@example.com"),
        name: "Email",
        errorText: "Incorrect email",
        focused: false,
        textContentType: .emailAddress,
        nameStyle: .pronounced
      )
      .previewScheme(.light)
      TextFieldBlock(
        text: .constant("email@example.com"),
        name: "Email",
        errorText: "Incorrect email",
        focused: false,
        textContentType: .emailAddress,
        nameStyle: .pronounced
      )
      .previewScheme(.dark)
      TextFieldBlock(
        text: .constant("s$9dk$9dk"),
        name: "Password",
        errorText: "Incorrect email",
        focused: false,
        textContentType: .password,
        secure: true
      )
      .previewScheme(.light)
      TextFieldBlock(
        text: .constant("s$9dk$9dk"),
        name: "Password",
        errorText: "Incorrect email",
        focused: false,
        textContentType: .password,
        secure: true
      )
      .previewScheme(.dark)
      TextFieldBlock(
        text: .constant("s$9dk$9dk"),
        name: "Password",
        errorText: "Incorrect email",
        focused: false,
        textContentType: .password,
        nameStyle: .pronounced,
        secure: true
      )
      .previewScheme(.light)
      TextFieldBlock(
        text: .constant("s$9dk$9dk"),
        name: "Password",
        errorText: "Incorrect email",
        focused: false,
        textContentType: .password,
        nameStyle: .pronounced,
        secure: true
      )
      .previewScheme(.dark)
    }
    .frame(height: 100)
    .previewLayout(.sizeThatFits)
  }
}
