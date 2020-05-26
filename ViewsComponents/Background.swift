//
//  Background.swift
//  ViewsComponents
//
//  Created by Dmytro Shapovalov on 14.04.2020.
//  Copyright © 2020 Dmytro Shapovalov. All rights reserved.
//

import SwiftUI

public struct AppBackground: ViewModifier {
  @Environment(\.colorScheme) var colorScheme
  
  public init() { }
  
  public func body(content: Content) -> some View {
    return content.background(colorScheme == .dark ?
    UIColor.Beckground.AppBackgroundColor.dark.sui : UIColor.Beckground.AppBackgroundColor.light.sui)
  }
}
