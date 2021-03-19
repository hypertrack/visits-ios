import SwiftUI

public struct LinkedText: UIViewRepresentable {
  // TODO: Add result builder API: https://github.com/apple/swift-evolution/blob/main/proposals/0289-result-builders.md
  public enum LinkedTextList {
    indirect case link(URL, text: String, next: LinkedTextList)
    indirect case text(String, next: LinkedTextList)
    case endingWithLink(URL, text: String)
    case endingWithText(String)
  }
  
  let textList: LinkedTextList

  public init(_ textList: LinkedTextList) {
    self.textList = textList
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
    uiView.attributedText = textList.attributedString
  }
}

extension LinkedText.LinkedTextList {
  var attributedString: NSAttributedString {
    fold(self, to: NSAttributedString())
  }
}

func fold(_ list: LinkedText.LinkedTextList, to string: NSAttributedString) -> NSAttributedString {
  let mutableString = NSMutableAttributedString(attributedString: string)
  
  let font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
  
  let attributesText: [NSAttributedString.Key: Any] = [
    .font: font,
    .foregroundColor: UIColor.greySuit
  ]
  var attributesLink: [NSAttributedString.Key: Any] = [
    .font: font,
    .foregroundColor: UIColor.dodgerBlue
  ]
  
  switch list {
  case let .link(url, text, next):
    attributesLink[.link] = url
    mutableString.append(NSAttributedString(string: text, attributes: attributesLink))
    return fold(next, to: mutableString)
  
  case let .text(text, next):
    mutableString.append(NSAttributedString(string: text, attributes: attributesText))
    return fold(next, to: mutableString)
  
  case let .endingWithLink(url, text):
    attributesLink[.link] = url
    mutableString.append(NSAttributedString(string: text, attributes: attributesLink))
    return mutableString
  
  case let .endingWithText(text):
    mutableString.append(NSAttributedString(string: text, attributes: attributesText))
    return mutableString
  }
}

struct LinkedText_Previews: PreviewProvider {
    static var previews: some View {
      LinkedText(
        .text(
          "By clicking on the Accept & Continue button I agree to ",
          next: .link(
            URL(string: "https://www.hypertrack.com/terms")!,
            text: "Terms of Service",
            next: .text(
              " and ",
              next: .endingWithLink(
                URL(string: "https://www.hypertrack.com/agreement")!,
                text: "HyperTrack SaaS Agreement"
              )
            )
          )
        )
      )
    }
}
