//
//  TextView.swift
//  ViewsComponents
//
//  Created by Dmytro Shapovalov on 14.04.2020.
//  Copyright © 2020 Dmytro Shapovalov. All rights reserved.
//

import SwiftUI

public struct TextView: View {
  @Environment(\.colorScheme) var colorScheme
  private let text: String
  
  public init(text: String) {
    self.text = text
  }
  
  public var body: some View {
    Text(text)
      .font(UIFont.TextView.textFont.sui)
  }
}

struct GrayTextViewModifier: ViewModifier {
  func body(content: Content) -> some View {
    content
      .foregroundColor(UIColor.TextView.grayTextColor.sui)
  }
}

fileprivate struct DefaultTextViewModifier: ViewModifier {
  @Environment(\.colorScheme) var colorScheme
  func body(content: Content) -> some View {
    content
      .foregroundColor(colorScheme == .dark ? UIColor.TextView.dark.sui : UIColor.TextView.light.sui)
  }
}

public extension TextView {
  func grayTextColor() -> some View {
    self.modifier(GrayTextViewModifier())
  }
  
  func defaultTextColor() -> some View {
    self.modifier(DefaultTextViewModifier(colorScheme: self._colorScheme))
  }
}

struct TextView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      TextView(text: "Link dark")
      .frame(width: 300, height: 48)
        .environment(\.colorScheme, .dark)
      TextView(text: "Link light")
      .frame(width: 300, height: 48)
        .environment(\.colorScheme, .light)
    }
  }
}
