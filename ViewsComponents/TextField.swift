//
//  TextField.swift
//  ViewsComponents
//
//  Created by Dmytro Shapovalov on 13.04.2020.
//  Copyright © 2020 Dmytro Shapovalov. All rights reserved.
//

import SwiftUI
import Combine


// MARK: -
// MARK: TextFieldView main view
private struct TextFieldView: UIViewRepresentable {
  let keyboardType: UIKeyboardType
  let returnKeyType: UIReturnKeyType
  let isSecureTextEntry: Bool
  @Binding var text: String
  let isFocused: Bool
  let enablesReturnKeyAutomatically: Bool
  let textContentType: UITextContentType?
  let enterButtonPressed: () -> Void
  let wantsToBecomeFocused: () -> Void
  
  func makeUIView(context: Context) -> UITextField {
    let textField = UITextField(frame: .zero)
    textField.keyboardType = self.keyboardType
    textField.returnKeyType = self.returnKeyType
    textField.delegate = context.coordinator
    textField.isSecureTextEntry = self.isSecureTextEntry
    textField.autocorrectionType = .no
    textField.enablesReturnKeyAutomatically = self.enablesReturnKeyAutomatically
    textField.textContentType = self.textContentType
    return textField
  }

  func updateUIView(_ uiView: UITextField, context: Context) {
    uiView.text = text
    if isFocused {
      if !uiView.isFirstResponder {
        uiView.becomeFirstResponder()
      }
    } else {
      uiView.resignFirstResponder()
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  class Coordinator: NSObject, UITextFieldDelegate {
    var parent: TextFieldView

    init(_ textField: TextFieldView) {
      self.parent = textField
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
      if !self.parent.isFocused { self.parent.wantsToBecomeFocused() }
      return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      self.parent.enterButtonPressed()
      return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
      if let text = textField.text,
         let textRange = Range(range, in: text) {
         let updatedText = text.replacingCharacters(in: textRange,
                                                     with: string)
        self.parent.text = updatedText
      }
      return false
    }
  }
}


// MARK: -
// MARK: PrimaryTextField
public struct PrimaryTextField: View {
  private let wantsToBecomeFocused: () -> Void
  private let onEnterButtonPressed: () -> Void
  private let placeholder: String
  private let keyboardType: UIKeyboardType
  private let returnKeyType: UIReturnKeyType
  private let errorText: String
  private let isFocused: Bool
  private let enablesReturnKeyAutomatically: Bool
  private let textContentType: UITextContentType
  @Binding private var text: String
  
  public init(
    placeholder: String,
    text: Binding<String>,
    isFocused: Bool,
    enablesReturnKeyAutomatically: Bool = false,
    errorText: String,
    textContentType: UITextContentType,
    keyboardType: UIKeyboardType = UIKeyboardType.default,
    returnKeyType: UIReturnKeyType = UIReturnKeyType.default,
    wantsToBecomeFocused: @escaping () -> Void = {},
    onEnterButtonPressed: @escaping () -> Void = {})
  {
    self.textContentType = textContentType
    self.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
    self.keyboardType = keyboardType
    self.returnKeyType = returnKeyType
    self.placeholder = placeholder
    self._text = text
    self.isFocused = isFocused
    self.errorText = errorText
    self.wantsToBecomeFocused = wantsToBecomeFocused
    self.onEnterButtonPressed = onEnterButtonPressed
  }
    
  public var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      Text(self.placeholder)
        .font(UIFont.TextField.PrimaryTextField.placeholderFont.sui)
        .foregroundColor(UIColor.TextField.PrimaryTextFieldColor.placeholderColor.sui)
      TextFieldView(keyboardType: self.keyboardType,
                    returnKeyType: self.returnKeyType,
                    isSecureTextEntry: false,
                    text: self.$text,
                    isFocused: self.isFocused,
                    enablesReturnKeyAutomatically: self.enablesReturnKeyAutomatically,
                    textContentType: self.textContentType,
                    enterButtonPressed: self.onEnterButtonPressed,
                    wantsToBecomeFocused: self.wantsToBecomeFocused)
        .frame(height: 29)
        .offset(y: 5)
      Rectangle()
        .foregroundColor(UIColor.TextField.PrimaryTextFieldColor.borderColor.sui)
        .frame(height: 1.0, alignment: .bottom)
        .padding(.top, 6)
      Text(self.errorText)
        .lineLimit(3)
        .font(UIFont.TextField.PrimaryTextField.placeholderFont.sui)
        .foregroundColor(UIColor.TextField.PrimaryTextFieldColor.errorColor.sui)
    }
    .contentShape(Rectangle())
    .onTapGesture { }
  }
}

struct PrimaryTextField_Previews: PreviewProvider {
  static var previews: some View {
    PrimaryTextField(placeholder: "Placeholder", text: .constant("Some text"), isFocused: false, errorText: "Some error text", textContentType: .emailAddress)
      .padding()
  }
}

// MARK: -
// MARK: SecureTextField
public struct SecureTextField: View {
  private let wantsToBecomeFocused: () -> Void
  private let onEnterButtonPressed: () -> Void
  private let placeholder: String
  private let returnKeyType: UIReturnKeyType
  private let errorText: String
  private let isFocused: Bool
  private let enablesReturnKeyAutomatically: Bool
  @Binding private var text: String
  
  public init(
    placeholder: String,
    text: Binding<String>,
    isFocused: Bool,
    enablesReturnKeyAutomatically: Bool = false,
    errorText: String,
    returnKeyType: UIReturnKeyType = UIReturnKeyType.default,
    wantsToBecomeFocused: @escaping () -> Void = {},
    onEnterButtonPressed: @escaping () -> Void = {})
  {
    self.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
    self.returnKeyType = returnKeyType
    self.placeholder = placeholder
    self._text = text
    self.isFocused = isFocused
    self.errorText = errorText
    self.wantsToBecomeFocused = wantsToBecomeFocused
    self.onEnterButtonPressed = onEnterButtonPressed
  }
    
  public var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      Text(self.placeholder)
        .font(UIFont.TextField.SecureTextField.placeholderFont.sui)
        .foregroundColor(UIColor.TextField.SecureTextFieldColor.placeholderColor.sui)
      TextFieldView(keyboardType: .default,
                    returnKeyType: self.returnKeyType,
                    isSecureTextEntry: true,
                    text: self.$text,
                    isFocused: self.isFocused,
                    enablesReturnKeyAutomatically: self.enablesReturnKeyAutomatically,
                    textContentType: .password,
                    enterButtonPressed: self.onEnterButtonPressed,
                    wantsToBecomeFocused: self.wantsToBecomeFocused)
        .frame(height: 29)
        .offset(y: 5)
      Rectangle()
        .foregroundColor(UIColor.TextField.PrimaryTextFieldColor.borderColor.sui)
        .frame(height: 1.0, alignment: .bottom)
        .padding(.top, 6)
      Text(self.errorText)
        .lineLimit(3)
        .font(UIFont.TextField.SecureTextField.placeholderFont.sui)
        .foregroundColor(UIColor.TextField.SecureTextFieldColor.errorColor.sui)
    }
    .contentShape(Rectangle())
    .onTapGesture { }
  }
}

struct SecureTextField_Previews: PreviewProvider {
  static var previews: some View {
    SecureTextField(placeholder: "Placeholder", text: .constant("Some text"), isFocused: false, errorText: "Some error text")
      .padding()
  }
}

// MARK: -
// MARK: ContentTextField
public struct ContentTextField: View {
  private let wantsToBecomeFocused: () -> Void
  private let onEnterButtonPressed: () -> Void
  private let placeholder: String
  private let keyboardType: UIKeyboardType
  private let returnKeyType: UIReturnKeyType
  private let errorText: String
  private let isFocused: Bool
  private let enablesReturnKeyAutomatically: Bool
  private let textContentType: UITextContentType?
  @Binding private var text: String
  @Environment(\.colorScheme) var colorScheme
  
  public init(
    placeholder: String,
    text: Binding<String>,
    isFocused: Bool,
    enablesReturnKeyAutomatically: Bool = false,
    errorText: String,
    textContentType: UITextContentType? = nil,
    keyboardType: UIKeyboardType = UIKeyboardType.default,
    returnKeyType: UIReturnKeyType = UIReturnKeyType.default,
    wantsToBecomeFocused: @escaping () -> Void = {},
    onEnterButtonPressed: @escaping () -> Void = {})
  {
    self.textContentType = textContentType
    self.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
    self.keyboardType = keyboardType
    self.returnKeyType = returnKeyType
    self.placeholder = placeholder
    self._text = text
    self.isFocused = isFocused
    self.errorText = errorText
    self.wantsToBecomeFocused = wantsToBecomeFocused
    self.onEnterButtonPressed = onEnterButtonPressed
  }
    
  public var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      Text(self.placeholder)
        .font(UIFont.TextField.PrimaryTextField.placeholderFont.sui)
        .foregroundColor(self.colorScheme == .dark ? UIColor.TableView.Cell.Title.dark.sui : UIColor.TableView.Cell.Title.light.sui)
      TextFieldView(keyboardType: self.keyboardType,
                    returnKeyType: self.returnKeyType,
                    isSecureTextEntry: false,
                    text: self.$text,
                    isFocused: self.isFocused,
                    enablesReturnKeyAutomatically: self.enablesReturnKeyAutomatically,
                    textContentType: self.textContentType,
                    enterButtonPressed: self.onEnterButtonPressed,
                    wantsToBecomeFocused: self.wantsToBecomeFocused)
        .frame(height: 29)
        .offset(y: 5)
      Rectangle()
        .foregroundColor(UIColor.TextField.PrimaryTextFieldColor.borderColor.sui)
        .frame(height: 1.0, alignment: .bottom)
        .padding(.top, 6)
      Text(self.errorText)
        .lineLimit(3)
        .font(UIFont.TextField.PrimaryTextField.placeholderFont.sui)
        .foregroundColor(UIColor.TextField.PrimaryTextFieldColor.errorColor.sui)
    }
    .contentShape(Rectangle())
    .onTapGesture { }
  }
}
