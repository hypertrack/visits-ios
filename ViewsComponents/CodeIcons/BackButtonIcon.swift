//
//  BackButtonIcon.swift
//  ViewsComponents
//
//  Created by Dmytro Shapovalov on 22.04.2020.
//  Copyright © 2020 HyperTrack. All rights reserved.
//

import SwiftUI
import Foundation

struct ArrowsShape: Shape {
  func path(in rect: CGRect) -> Path {
    var shapePath = Path()
    shapePath.move(to: CGPoint(x: 10.54, y: 20.57))
    shapePath.addLine(to: CGPoint(x: 1.29, y: 11.21))
    shapePath.addCurve(to: CGPoint(x: 1.29, y: 9.79), control1: CGPoint(x: 0.9, y: 10.82), control2: CGPoint(x: 0.9, y: 10.18))
    shapePath.addLine(to: CGPoint(x: 10.54, y: 0.43))
    shapePath.addCurve(to: CGPoint(x: 12.58, y: 0.43), control1: CGPoint(x: 11.1, y: -0.14), control2: CGPoint(x: 12.01, y: -0.14))
    shapePath.addCurve(to: CGPoint(x: 12.58, y: 2.49), control1: CGPoint(x: 13.14, y: 1), control2: CGPoint(x: 13.14, y: 1.92))
    shapePath.addLine(to: CGPoint(x: 4.67, y: 10.5))
    shapePath.addLine(to: CGPoint(x: 12.58, y: 18.51))
    shapePath.addCurve(to: CGPoint(x: 12.58, y: 20.57), control1: CGPoint(x: 13.14, y: 19.08), control2: CGPoint(x: 13.14, y: 20))
    shapePath.addCurve(to: CGPoint(x: 10.54, y: 20.57), control1: CGPoint(x: 12.01, y: 21.14), control2: CGPoint(x: 11.1, y: 21.14))
    return shapePath
  }
}

public struct BackButtonIcon: View {
  @Environment(\.colorScheme) var colorScheme
  
  public init() { }
  
  public var body: some View {
    let fillColor = colorScheme == .dark ? UIColor.Button.NavigationButton.BeckgroundColor.dark.sui : UIColor.Button.NavigationButton.BeckgroundColor.light.sui
    return ZStack {
      ArrowsShape()
        .fill(fillColor)
    }
  }
}


