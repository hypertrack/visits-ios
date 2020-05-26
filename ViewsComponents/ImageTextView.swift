//
//  ImageTextView.swift
//  ViewsComponents
//
//  Created by Dmytro Shapovalov on 15.04.2020.
//  Copyright © 2020 Dmytro Shapovalov. All rights reserved.
//

import SwiftUI
import Prelude

public struct ImageTextView: View {
  @Environment(\.colorScheme) var colorScheme
  let text: NonEmptyString
  
  public init(title: NonEmptyString)
  {
    self.text = title
  }
  
  public var body: some View {
    HStack {
      CheckIcon().frame(width: 24, height: 24)
      Text(self.text.rawValue)
        .font(UIFont.ImageTextView.titleFont.sui)
        .foregroundColor(colorScheme == .dark ? UIColor.ImageTextView.TitleViewColor.dark.sui : UIColor.ImageTextView.TitleViewColor.light.sui)
    }
  }
}

struct ImageTextView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      ImageTextView(title: "Verify your email")
        .environment(\.colorScheme, .dark)
      ImageTextView(title: "Verify your email")
        .environment(\.colorScheme, .light)
    }
  }
}
