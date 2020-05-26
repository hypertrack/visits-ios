//
//  CheckIcon.swift
//  ViewsComponents
//
//  Created by Dmytro Shapovalov on 15.04.2020.
//  Copyright © 2020 Dmytro Shapovalov. All rights reserved.
//

import Foundation
import SwiftUI

struct CircleShape: Shape {
  func path(in rect: CGRect) -> Path {
    var bezierPath = Path()
    bezierPath.move(to: CGPoint(x: 12, y: 24))
    bezierPath.addCurve(to: CGPoint(x: 24, y: 12), control1: CGPoint(x: 18.63, y: 24), control2: CGPoint(x: 24, y: 18.63))
    bezierPath.addCurve(to: CGPoint(x: 12, y: 0), control1: CGPoint(x: 24, y: 5.37), control2: CGPoint(x: 18.63, y: 0))
    bezierPath.addCurve(to: CGPoint(x: 0, y: 12), control1: CGPoint(x: 5.37, y: 0), control2: CGPoint(x: 0, y: 5.37))
    bezierPath.addCurve(to: CGPoint(x: 12, y: 24), control1: CGPoint(x: 0, y: 18.63), control2: CGPoint(x: 5.37, y: 24))
    return bezierPath
  }
}

struct CheckShape: Shape {
  func path(in rect: CGRect) -> Path {
    var bezierPath = Path()
    bezierPath.move(to: CGPoint(x: 9.75, y: 14.61))
    bezierPath.addLine(to: CGPoint(x: 6.7, y: 11.65))
    bezierPath.addCurve(to: CGPoint(x: 5.28, y: 11.67), control1: CGPoint(x: 6.3, y: 11.26), control2: CGPoint(x: 5.67, y: 11.27))
    bezierPath.addCurve(to: CGPoint(x: 5.3, y: 13.08), control1: CGPoint(x: 4.9, y: 12.06), control2: CGPoint(x: 4.91, y: 12.7))
    bezierPath.addLine(to: CGPoint(x: 9.05, y: 16.72))
    bezierPath.addCurve(to: CGPoint(x: 10.45, y: 16.72), control1: CGPoint(x: 9.44, y: 17.09), control2: CGPoint(x: 10.06, y: 17.09))
    bezierPath.addLine(to: CGPoint(x: 18.7, y: 8.72))
    bezierPath.addCurve(to: CGPoint(x: 18.72, y: 7.3), control1: CGPoint(x: 19.09, y: 8.33), control2: CGPoint(x: 19.1, y: 7.7))
    bezierPath.addCurve(to: CGPoint(x: 17.3, y: 7.28), control1: CGPoint(x: 18.33, y: 6.91), control2: CGPoint(x: 17.7, y: 6.9))
    bezierPath.addLine(to: CGPoint(x: 9.75, y: 14.61))
    return bezierPath
  }
}

public struct CheckIcon: View {
  public init() { }
  
  public var body: some View {
    ZStack {
      CircleShape()
        .fill(Color.blue)
      CheckShape()
      .fill(Color.white)
    }
  }
}
