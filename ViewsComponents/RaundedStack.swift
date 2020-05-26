//
//  RaundedStack.swift
//  ViewsComponents
//
//  Created by Dmytro Shapovalov on 23.04.2020.
//  Copyright © 2020 HyperTrack. All rights reserved.
//

import SwiftUI

public struct RaundedStack<Content: View>: View {
  @Environment(\.colorScheme) var colorScheme
  private let content: () -> Content
  private let isVisible: Bool
  
  public init (isVisible: Bool, @ViewBuilder content: @escaping () -> Content) {
    self.content = content
    self.isVisible = isVisible
  }
  
  public var body: some View {
    GeometryReader { geometry in
      VStack(spacing: 0.0) {
        Spacer()
        VStack(spacing: 0.0) {
          self.content()
        }
        .frame(height: 88.0)
        .background(self.colorScheme == .dark ? UIColor.RaundedStack.dark.sui : UIColor.RaundedStack.light.sui)
        .cornerRadius(10.0)
        .shadow(radius: 10.0)
      }
      .frame(width: geometry.size.width)
    }.opacity(self.isVisible ? 1 : 0)
  }
}

struct RaundedStack_Previews: PreviewProvider {
  static var previews: some View {
    RaundedStack(isVisible: true) {
      PrimaryButton(
        state: .normal,
        isActivityVisible: false,
        title: "Complete geofence"
      ) {  }
        .padding([.trailing, .leading], 58)
    }
  }
}
