//
//  HyperLinkTextView.swift
//  ViewsComponents
//
//  Created by Dmytro Shapovalov on 14.04.2020.
//  Copyright © 2020 Dmytro Shapovalov. All rights reserved.
//

import SwiftUI
import UIKit
import Prelude

public struct LinkModel {
  let linkTextRange: NSRange
  let linkURL: NonEmptyString
  
  public init(_ linkTextRange: NSRange,
              _ linkURL: NonEmptyString) {
    self.linkTextRange = linkTextRange
    self.linkURL = linkURL
  }
}

public struct HyperLinkTextView: UIViewRepresentable {
  private let text: NonEmptyString
  private let hyperLinkTextList: NonEmptyArray<LinkModel>
  
  public init(
    text: NonEmptyString,
    hyperLinkTextList: NonEmptyArray<LinkModel>)
  {
    self.text = text
    self.hyperLinkTextList = hyperLinkTextList
  }
  
  public func makeUIView(context _: Context) -> UITextView {
    let textView = UITextView()
    textView.isScrollEnabled = true
    textView.isEditable = false
    textView.isUserInteractionEnabled = true
    textView.backgroundColor = .clear
    textView.autocorrectionType = .no
    return textView
  }
  
  public func updateUIView(_ uiView: UITextView, context _: Context) {
    let attributedString =
      NSMutableAttributedString(
        string: self.text.rawValue,
        attributes: [
          .font: UIFont.HyperLinkTextView.textFont,
          .foregroundColor: UIColor.HyperLinkTextView.textColor
        ]
      )
    
    for linkModel in hyperLinkTextList.rawValue {
      if let link = URL(string: linkModel.linkURL.rawValue) {
        attributedString.setAttributes(
          [.link: link],
          range: linkModel.linkTextRange
        )
        attributedString.addAttribute(
          NSAttributedString.Key.font,
          value: UIFont.HyperLinkTextView.textFont,
          range: linkModel.linkTextRange
        )
      }
    }
    
    
    uiView.attributedText = attributedString
  }
}

struct HyperLinkTextView_Previews: PreviewProvider {
  static var previews: some View {
    let text = NonEmptyString(stringLiteral: "By clicking on the Accept & Continue button I agree to Terms of Service and HyperTrack SaaS Agreement")
    let itemList = NonEmptyArray(
      LinkModel(NSMakeRange(50, 11), "https://www.hypertrack.com/terms"),
      LinkModel(NSMakeRange(76, 25), "https://www.hypertrack.com/agreement"))
    return Group {
      HyperLinkTextView(text: text, hyperLinkTextList: itemList).environment(\.colorScheme, .dark)
      HyperLinkTextView(text: text, hyperLinkTextList: itemList).environment(\.colorScheme, .light)
    }
  }
}
