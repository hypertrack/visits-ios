//
//  NotificationView.swift
//  ViewsComponents
//
//  Created by Dmytro Shapovalov on 22.04.2020.
//  Copyright © 2020 HyperTrack. All rights reserved.
//

import SwiftUI

public struct NotificationView: View {
  private let text: String
  private let state: NotificationViewBackgroundColor
  
  public enum NotificationViewBackgroundColor {
    case primary
    case onVisited
    case onCompleted
    case custom(color: Color)
  }
  
  public init(text: String, state: NotificationViewBackgroundColor) {
    self.text = text
    self.state = state
  }
  
  public var body: some View {
    HStack(spacing: 0) {
      Spacer()
      if self.text.isEmpty {
        EmptyView()
      } else {
        Text(self.text)
          .font(UIFont.NotificationView.textFont.sui)
          .foregroundColor(UIColor.NotificationView.textColor.sui)
      }
      Spacer()
    }
    .padding(self.text.isEmpty ? 0 : 10)
    .background(self.getBackground())
  }
  
  private func getBackground() -> some View {
    switch state {
    case .primary:
      return UIColor.NotificationView.BackgroundColor.primaryBackgroundColor.sui
    case .onVisited:
      return UIColor.NotificationView.BackgroundColor.onVisitedBackgroundColor.sui
    case .onCompleted:
      return UIColor.NotificationView.BackgroundColor.onCompletedBackgroundColor.sui
    case let .custom(color):
      return color
    }
  }
}

struct NotificationView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      NotificationView(text: "Some text", state: .onCompleted).environment(\.colorScheme, .light)
      NotificationView(text: "Some text", state: .onVisited).environment(\.colorScheme, .dark)
      NotificationView(text: "Some text", state: .primary).environment(\.colorScheme, .dark)
    }
  }
}
