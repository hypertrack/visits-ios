//
//  NavigationViewBackground.swift
//  ViewsComponents
//
//  Created by Dmytro Shapovalov on 21.04.2020.
//  Copyright © 2020 HyperTrack. All rights reserved.
//

import SwiftUI

// MARK: -
// MARK: Navigation
public struct Navigation<Leading: View, Trailing: View, Content: View>: View {
  @Environment(\.colorScheme) var colorScheme
  private let leading: () -> Leading
  private let trailing: () -> Trailing
  private let content: () -> Content
  private let title: String
  
  public init(
    title: String,
    @ViewBuilder leading: @escaping () -> Leading,
    @ViewBuilder trailing: @escaping () -> Trailing,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.leading = leading
    self.trailing = trailing
    self.content = content
    self.title = title
  }
  
  public var body: some View {
    ZStack {
      self.nagivationView.zIndex(1)
      self.content().zIndex(0)
    }
  }
  
  private var nagivationView: some View {
    GeometryReader { geometry in
        VStack(spacing: 0) {
          Rectangle()
            .fill(self.colorScheme == .dark ? UIColor.NavigationView.BackgroundColor.dark.sui : UIColor.NavigationView.BackgroundColor.light.sui)
            .frame(height: geometry.safeAreaInsets.top > 20.0 ? geometry.safeAreaInsets.top : 20)
          ZStack {
            HStack {
              self.leading()
                .padding(.leading, 16)
              Spacer()
              self.trailing()
                .padding(.trailing, 16)
            }
            .frame(width: geometry.size.width, height: 44)
            .background(self.colorScheme == .dark ? UIColor.NavigationView.BackgroundColor.dark.sui : UIColor.NavigationView.BackgroundColor.light.sui)
            Text(self.title)
              .frame(width: geometry.size.width / 1.5, height: 44)
              .font(UIFont.NavigationView.titleFont.sui)
              .foregroundColor(self.colorScheme == .dark ? UIColor.NavigationView.TitleColor.dark.sui : UIColor.NavigationView.TitleColor.light.sui)
          }
          Spacer()
        }
        .clipped()
        .shadow(radius: 5)
        .edgesIgnoringSafeArea(.top)
    }
  }
}

struct NavigationViewI_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      Navigation(
        title: "1201 16th St Mall, Denver, CO 80202,",
        leading: {
          Button(action: {}, label: { Text("backButton")})
        },
        trailing: {
          Button(action: {}, label: { Text("nextButton")})
        },
        content: {
          Text("Content")
      }).previewDevice(PreviewDevice(rawValue: "iPhone 8")).environment(\.colorScheme, .dark)
      Navigation(
        title: "Title",
        leading: {
          Button(action: {}, label: { Text("backButton")})
        },
        trailing: {
          Button(action: {}, label: { Text("nextButton")})
        },
        content: {
          
          Text("Content")
          
      }).previewDevice(PreviewDevice(rawValue: "iPhone X")).environment(\.colorScheme, .light)
    }
  }
}
