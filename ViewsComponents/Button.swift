//
//  Button.swift
//  ViewsComponents
//
//  Created by Dmytro Shapovalov on 13.04.2020.
//  Copyright © 2020 Dmytro Shapovalov. All rights reserved.
//

import SwiftUI


// MARK: -
// MARK: PrimaryButton
fileprivate struct PrimaryButtonStyle: ButtonStyle {
  private let state: PrimaryButton.State
  private let gradientGreenState = LinearGradient(
    gradient: Gradient(
      colors: [UIColor.Button.PrimaryBtColor.GreenGradientState.gradientStartColor.sui,
               UIColor.Button.PrimaryBtColor.GreenGradientState.gradientEndColor.sui]
    ),
    startPoint: .leading,
    endPoint: .trailing
  )
  private let gradientRedState = LinearGradient(
    gradient: Gradient(
      colors: [UIColor.Button.PrimaryBtColor.RedGradientState.gradientStartColor.sui,
               UIColor.Button.PrimaryBtColor.RedGradientState.gradientEndColor.sui]
    ),
    startPoint: .leading,
    endPoint: .trailing
  )
  
  init(state: PrimaryButton.State) {
    self.state = state
  }
  
  func makeBody(configuration: Self.Configuration) -> some View {
    configuration.label
      .frame(height: 48)
      .font(UIFont.Button.primaryBtFont.sui)
      .foregroundColor(Color.white)
      .background(self.beckgroundFromCurrentState(state: self.state, isPressed: configuration.isPressed))
      .cornerRadius(24)
  }
  
  func beckgroundFromCurrentState(state: PrimaryButton.State, isPressed: Bool) -> some View {
    switch state {
    case .normal:
      if isPressed {
        return ZStack { self.gradientGreenState; Color(UIColor.clear) }
      } else {
        return ZStack { self.gradientGreenState; Color(UIColor.Button.PrimaryBtColor.pressedColor).opacity(0.16) }
      }
    case .destructive:
      if isPressed {
        return ZStack { self.gradientRedState; Color(UIColor.clear) }
      } else {
        return ZStack { self.gradientRedState; Color(UIColor.Button.PrimaryBtColor.pressedColor).opacity(0.16) }
      }
    case .disabled:
      return ZStack {
        LinearGradient(gradient: Gradient(colors: [Color.clear]), startPoint: .leading, endPoint: .trailing)
        Color(UIColor.Button.PrimaryBtColor.disabledColor).opacity(0.16)
      }
    }
  }
}

fileprivate struct ButtonActivityIndicator: UIViewRepresentable {
  let style: UIActivityIndicatorView.Style
  let color: UIColor
  let animating: Bool
  
  init(style: UIActivityIndicatorView.Style = .medium,
       color: UIColor = .white,
       animating: Bool
  ) {
    self.style = style
    self.color = color
    self.animating = animating
  }

  func makeUIView(context: UIViewRepresentableContext<ButtonActivityIndicator>) -> UIActivityIndicatorView {
    let activity = UIActivityIndicatorView(style: style)
    activity.hidesWhenStopped = true
    activity.color = color
    return activity
  }

  func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ButtonActivityIndicator>) {
    if animating {
      uiView.startAnimating()
    } else {
      uiView.stopAnimating()
    }
  }
}

public struct PrimaryButton: View {
  private let state: State
  private let isActivityVisible: Bool
  private let title: String
  private let destructiveTitle: String
  private let onTapAction: () -> Void
  
  public enum State {
    case normal
    case destructive
    case disabled
  }
  
  public init(
    state: State = .normal,
    isActivityVisible: Bool = false,
    title: String,
    destructiveTitle: String = "Cancel",
    _ onTapAction: @escaping () -> Void)
  {
    self.state = state
    self.isActivityVisible = isActivityVisible
    self.destructiveTitle = destructiveTitle
    self.title = title
    self.onTapAction = onTapAction
  }
  
  public var body: some View {
    Button(action: onTapAction) {
      HStack {
        Spacer()
        Text(self.state == .destructive ? destructiveTitle : title)
          .padding([.leading, .trailing], self.isActivityVisible ? 0 : 20)
        if self.isActivityVisible {
          ButtonActivityIndicator(animating: true)
        }
        Spacer()
      }
    }
    .buttonStyle(PrimaryButtonStyle(state: self.state))
    .disabled(self.state == .disabled)
  }
}

struct PrimaryButton_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      PrimaryButton(title: "Button title", { })
        .frame(width: 300, height: 48)
      PrimaryButton(state: .destructive, isActivityVisible: false, title: "Primary", {})
        .frame(width: 300, height: 48)
    }
  }
}

// MARK: -
// MARK: SecondaryButton
fileprivate struct SecondaryButtonStyle: ButtonStyle {
  @Environment(\.colorScheme) var colorScheme
  
  func makeBody(configuration: Self.Configuration) -> some View {
      configuration.label
        .frame(height: 48)
        .font(UIFont.Button.secondaryBtFont.sui)
        .foregroundColor(colorScheme == .dark ?
          UIColor.Button.SecondaryBtColor.TitleColor.dark.sui : UIColor.Button.SecondaryBtColor.TitleColor.light.sui)
  }
}

public struct SecondaryButton: View {
  @Environment(\.colorScheme) var colorScheme
  private let title: String
  private let onTapAction: () -> Void
  
  public init(title: String,
              _ onTapAction: @escaping () -> Void)
  {
    self.title = title
    self.onTapAction = onTapAction
  }
  
  public var body: some View {
    Button(action: onTapAction) {
      HStack {
        Spacer()
        Text(title)
        Spacer()
      }
    }
    .buttonStyle(
      SecondaryButtonStyle(colorScheme: self._colorScheme)
    )
  }
}

struct SecondaryButton_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      SecondaryButton(title: "Button dark", { })
      .frame(width: 300, height: 48)
        .environment(\.colorScheme, .dark)
      SecondaryButton(title: "Button light", { })
      .frame(width: 300, height: 48)
        .environment(\.colorScheme, .light)
    }
    
  }
}


// MARK: -
// MARK: TransparentButton
fileprivate struct TransparentButtonStyle: ButtonStyle {
  @Environment(\.colorScheme) var colorScheme
  
  func makeBody(configuration: Self.Configuration) -> some View {
      configuration.label
        .frame(height: 48)
        .font(UIFont.Button.transparentBtFont.sui)
        .foregroundColor(UIColor.Button.TransparentButton.TitleColor.default.sui)
        .background(
          RoundedRectangle(cornerRadius: 40)
            .fill(colorScheme == .dark ? UIColor.Button.TransparentButton.BeckgroundColor.dark.sui : UIColor.Button.TransparentButton.BeckgroundColor.light.sui)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(colorScheme == .dark ?
                  UIColor.Button.TransparentButton.BorderColor.dark.sui : UIColor.Button.TransparentButton.BorderColor.light.sui, lineWidth: 1)
        )
  }
}

public struct TransparentButton: View {
  @Environment(\.colorScheme) var colorScheme
  private let title: String
  private let onTapAction: () -> Void
  
  public init(title: String,
              _ onTapAction: @escaping () -> Void)
  {
    self.title = title
    self.onTapAction = onTapAction
  }
  
  public var body: some View {
    Button(action: onTapAction) {
      HStack {
        Spacer()
        Text(title)
        Spacer()
      }
    }
    .buttonStyle(
      TransparentButtonStyle(colorScheme: self._colorScheme)
    )
  }
}

struct TransparentButton_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      TransparentButton(title: "Button dark", { })
      .frame(width: 300, height: 48)
        .environment(\.colorScheme, .dark)
      TransparentButton(title: "Button light", { })
      .frame(width: 300, height: 48)
        .environment(\.colorScheme, .light)
    }
  }
}

// MARK: -
// MARK: LinkButton
struct LinkButtonStyle: ButtonStyle {
  @Environment(\.colorScheme) var colorScheme
  
  func makeBody(configuration: Self.Configuration) -> some View {
      configuration.label
        .frame(height: 48)
        .font(UIFont.Button.linkBtFont.sui)
        .foregroundColor(UIColor.Button.LinkButton.titleColor.sui)
  }
}

public struct LinkButton: View {
  @Environment(\.colorScheme) var colorScheme
  private let title: String
  private let onTapAction: () -> Void
  
  public init(title: String,
              _ onTapAction: @escaping () -> Void)
  {
    self.title = title
    self.onTapAction = onTapAction
  }
  
  public var body: some View {
    Button(action: onTapAction) {
      HStack {
        Spacer()
        Text(title)
        Spacer()
      }
    }
    .buttonStyle(
      LinkButtonStyle(colorScheme: self._colorScheme)
    )
  }
}

struct LinkButton_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      LinkButton(title: "Link dark", { })
      .frame(width: 300, height: 48)
        .environment(\.colorScheme, .dark)
      LinkButton(title: "Link light", { })
      .frame(width: 300, height: 48)
        .environment(\.colorScheme, .light)
    }
  }
}

// MARK: -
// MARK: NavigationRefreshButton
public struct NavigationRefreshButton: View {
  @Environment(\.colorScheme) var colorScheme
  private let isButtonDisabled: Bool
  private let isRefreshing: Bool
  private let onTapAction: () -> Void
  
  public init(isDisabled: Bool, isRefreshing: Bool, _ onTapAction: @escaping () -> Void)
  {
    self.isButtonDisabled = isDisabled
    self.isRefreshing = isRefreshing
    self.onTapAction = onTapAction
  }
  
  public var body: some View {
    Button(action: onTapAction) {
      if self.isRefreshing {
        ButtonActivityIndicator(color: self.colorScheme == .light ? UIColor.black : UIColor.white, animating: true)
      } else {
        RefreshIcon()
          .frame(width: 28, height: 28)
          .opacity(self.isButtonDisabled ? 0.5 : 1.0)
      }
    }
    .disabled((self.isRefreshing || self.isButtonDisabled))
  }
}

struct NavigationefreshButton_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      NavigationRefreshButton(isDisabled: true, isRefreshing: true, { })
      .frame(width: 300, height: 48)
        .environment(\.colorScheme, .dark)
      NavigationRefreshButton(isDisabled: false, isRefreshing: false, { })
      .frame(width: 300, height: 48)
        .environment(\.colorScheme, .light)
    }
  }
}

// MARK: -
// MARK: NavigationBackButton
public struct NavigationBackButton: View {
  @Environment(\.colorScheme) var colorScheme
  private let onTapAction: () -> Void
  
  public init(_ onTapAction: @escaping () -> Void)
  {
    self.onTapAction = onTapAction
  }
  
  public var body: some View {
    Button(action: onTapAction) {
      BackButtonIcon().frame(width: 15, height: 21)
    }
  }
}

struct NavigationBackButton_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      NavigationBackButton({ })
      .frame(width: 300, height: 48)
        .environment(\.colorScheme, .dark)
      NavigationBackButton({ })
      .frame(width: 300, height: 48)
        .environment(\.colorScheme, .light)
    }
  }
}
