//
//  TitleView.swift
//  ViewsComponents
//
//  Created by Dmytro Shapovalov on 14.04.2020.
//  Copyright © 2020 Dmytro Shapovalov. All rights reserved.
//
import SwiftUI

// MARK: -
// MARK: TitleView
public struct TitleView: View {
  @Environment(\.colorScheme) var colorScheme
  private let titleText: String
  private let subTitleText: String
  
  public init(title: String, subTitle: String = "") {
    self.titleText = title
    self.subTitleText = subTitle
  }
  
  public var body: some View {
    GeometryReader { geometry in
      VStack(alignment: .center, spacing: 0.0) {
        Text(self.titleText)
          .font(UIFont.TitleView.titleFont.sui)
          .foregroundColor(self.colorScheme == .dark ?
            UIColor.TitleView.TitleColor.dark.sui : UIColor.TitleView.TitleColor.light.sui)
          .padding(.top, 44)
        Text(self.subTitleText)
          .font(UIFont.TitleView.subtitleFont.sui)
          .foregroundColor(self.colorScheme == .dark ?
            UIColor.TitleView.subTitleColor.dark.sui : UIColor.TitleView.subTitleColor.light.sui)
      }
      .frame(width: geometry.size.width, height: 94)
      .modifier(AppBackground())
    }.frame(height: 94)
  }
}

struct TitleView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      TitleView(title: "Sign up a new account", subTitle: "14 day free trial. No Credit card required")
        .environment(\.colorScheme, .dark)
      TitleView(title: "Sign up a new account", subTitle: "14 day free trial. No Credit card required")
        .environment(\.colorScheme, .light)
    }
  }
}
