import SwiftUI

import Prelude
import ViewsComponents


struct Block: View {
  let title: NonEmptyString
  let message: NonEmptyString
  let showsButton: Bool
  let buttonTitle: String
  let buttonPressed: () -> Void
  
  
  init(
    title: NonEmptyString,
    message: NonEmptyString,
    showsButton: Bool,
    buttonTitle: String,
    buttonPressed: @escaping () -> Void
  ) {
    self.title = title
    self.message = message
    self.showsButton = showsButton
    self.buttonTitle = buttonTitle
    self.buttonPressed = buttonPressed
  }
  
  var body: some View {
      VStack {
        TitleView(title: title.rawValue)
      TextView(text: message.rawValue)
        .defaultTextColor()
        .padding(.top, 30)
        .padding([.trailing, .leading], 16)
        Spacer()
      if self.showsButton {
        PrimaryButton(
          state: .normal,
          title: buttonTitle,
          buttonPressed
        )
        .padding(.bottom, 40)
        .padding([.trailing, .leading], 58)
      }
    }
    .modifier(AppBackground())
    .edgesIgnoringSafeArea(.all)
  }
}
