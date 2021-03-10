import SwiftUI
import Foundation

private struct ArrowFirstShape: Shape {
  func path(in rect: CGRect) -> Path {
    var shapePath = Path()
    shapePath.move(to: CGPoint(x: 8.56, y: 11.35))
    shapePath.addCurve(to: CGPoint(x: 7.08, y: 11.33), control1: CGPoint(x: 8.16, y: 10.92), control2: CGPoint(x: 7.49, y: 10.91))
    shapePath.addLine(to: CGPoint(x: 5.77, y: 12.66))
    shapePath.addCurve(to: CGPoint(x: 5.59, y: 12.84), control1: CGPoint(x: 5.74, y: 12.7), control2: CGPoint(x: 5.67, y: 12.77))
    shapePath.addCurve(to: CGPoint(x: 12.8, y: 4.63), control1: CGPoint(x: 5.84, y: 8.68), control2: CGPoint(x: 8.8, y: 5.27))
    shapePath.addCurve(to: CGPoint(x: 20.88, y: 8.05), control1: CGPoint(x: 15.89, y: 4.14), control2: CGPoint(x: 18.99, y: 5.45))
    shapePath.addCurve(to: CGPoint(x: 21.76, y: 8.43), control1: CGPoint(x: 21.09, y: 8.34), control2: CGPoint(x: 21.42, y: 8.48))
    shapePath.addCurve(to: CGPoint(x: 22.19, y: 8.24), control1: CGPoint(x: 21.92, y: 8.4), control2: CGPoint(x: 22.06, y: 8.34))
    shapePath.addCurve(to: CGPoint(x: 22.55, y: 7.32), control1: CGPoint(x: 22.46, y: 8.03), control2: CGPoint(x: 22.6, y: 7.67))
    shapePath.addCurve(to: CGPoint(x: 22.37, y: 6.88), control1: CGPoint(x: 22.52, y: 7.16), control2: CGPoint(x: 22.46, y: 7.01))
    shapePath.addCurve(to: CGPoint(x: 12.52, y: 2.7), control1: CGPoint(x: 20.06, y: 3.7), control2: CGPoint(x: 16.29, y: 2.1))
    shapePath.addCurve(to: CGPoint(x: 3.71, y: 12.84), control1: CGPoint(x: 7.6, y: 3.49), control2: CGPoint(x: 3.96, y: 7.71))
    shapePath.addCurve(to: CGPoint(x: 3.65, y: 12.76), control1: CGPoint(x: 3.69, y: 12.81), control2: CGPoint(x: 3.66, y: 12.78))
    shapePath.addLine(to: CGPoint(x: 2.26, y: 11.26))
    shapePath.addCurve(to: CGPoint(x: 0.77, y: 11.24), control1: CGPoint(x: 1.85, y: 10.83), control2: CGPoint(x: 1.19, y: 10.82))
    shapePath.addCurve(to: CGPoint(x: 0.75, y: 12.79), control1: CGPoint(x: 0.36, y: 11.66), control2: CGPoint(x: 0.35, y: 12.36))
    shapePath.addLine(to: CGPoint(x: 3.87, y: 16.12))
    shapePath.addCurve(to: CGPoint(x: 4.64, y: 16.45), control1: CGPoint(x: 4.08, y: 16.35), control2: CGPoint(x: 4.36, y: 16.46))
    shapePath.addCurve(to: CGPoint(x: 5.35, y: 16.14), control1: CGPoint(x: 4.9, y: 16.45), control2: CGPoint(x: 5.15, y: 16.34))
    shapePath.addLine(to: CGPoint(x: 8.54, y: 12.9))
    shapePath.addCurve(to: CGPoint(x: 8.56, y: 11.35), control1: CGPoint(x: 8.96, y: 12.47), control2: CGPoint(x: 8.97, y: 11.78))
    shapePath.move(to: CGPoint(x: 4.68, y: 14.31))
    shapePath.addCurve(to: CGPoint(x: 4.71, y: 14.3), control1: CGPoint(x: 4.69, y: 14.3), control2: CGPoint(x: 4.7, y: 14.3))
    shapePath.addCurve(to: CGPoint(x: 4.68, y: 14.31), control1: CGPoint(x: 4.7, y: 14.32), control2: CGPoint(x: 4.69, y: 14.32))
    return shapePath
  }
}

private struct ArrowSecondShape: Shape {
  func path(in rect: CGRect) -> Path {
    var bezierPath = Path()
    bezierPath.move(to: CGPoint(x: 27.25, y: 14.26))
    bezierPath.addLine(to: CGPoint(x: 24.13, y: 10.93))
    bezierPath.addCurve(to: CGPoint(x: 23.36, y: 10.6), control1: CGPoint(x: 23.92, y: 10.7), control2: CGPoint(x: 23.64, y: 10.59))
    bezierPath.addCurve(to: CGPoint(x: 22.65, y: 10.91), control1: CGPoint(x: 23.1, y: 10.61), control2: CGPoint(x: 22.85, y: 10.71))
    bezierPath.addLine(to: CGPoint(x: 19.46, y: 14.16))
    bezierPath.addCurve(to: CGPoint(x: 19.44, y: 15.71), control1: CGPoint(x: 19.04, y: 14.58), control2: CGPoint(x: 19.03, y: 15.27))
    bezierPath.addCurve(to: CGPoint(x: 20.92, y: 15.73), control1: CGPoint(x: 19.84, y: 16.14), control2: CGPoint(x: 20.51, y: 16.15))
    bezierPath.addLine(to: CGPoint(x: 22.23, y: 14.39))
    bezierPath.addCurve(to: CGPoint(x: 22.39, y: 14.23), control1: CGPoint(x: 22.26, y: 14.35), control2: CGPoint(x: 22.32, y: 14.29))
    bezierPath.addCurve(to: CGPoint(x: 15.19, y: 22.37), control1: CGPoint(x: 22.12, y: 18.36), control2: CGPoint(x: 19.17, y: 21.74))
    bezierPath.addCurve(to: CGPoint(x: 7.11, y: 18.95), control1: CGPoint(x: 12.09, y: 22.86), control2: CGPoint(x: 9, y: 21.55))
    bezierPath.addCurve(to: CGPoint(x: 6.22, y: 18.57), control1: CGPoint(x: 6.9, y: 18.66), control2: CGPoint(x: 6.56, y: 18.52))
    bezierPath.addCurve(to: CGPoint(x: 5.8, y: 18.76), control1: CGPoint(x: 6.07, y: 18.6), control2: CGPoint(x: 5.92, y: 18.66))
    bezierPath.addCurve(to: CGPoint(x: 5.44, y: 19.68), control1: CGPoint(x: 5.53, y: 18.97), control2: CGPoint(x: 5.39, y: 19.33))
    bezierPath.addCurve(to: CGPoint(x: 5.62, y: 20.12), control1: CGPoint(x: 5.47, y: 19.84), control2: CGPoint(x: 5.53, y: 19.99))
    bezierPath.addCurve(to: CGPoint(x: 15.47, y: 24.3), control1: CGPoint(x: 7.93, y: 23.3), control2: CGPoint(x: 11.7, y: 24.9))
    bezierPath.addCurve(to: CGPoint(x: 24.27, y: 14.2), control1: CGPoint(x: 20.38, y: 23.51), control2: CGPoint(x: 24.01, y: 19.31))
    bezierPath.addCurve(to: CGPoint(x: 24.35, y: 14.29), control1: CGPoint(x: 24.3, y: 14.23), control2: CGPoint(x: 24.33, y: 14.27))
    bezierPath.addLine(to: CGPoint(x: 25.74, y: 15.79))
    bezierPath.addCurve(to: CGPoint(x: 27.23, y: 15.81), control1: CGPoint(x: 26.15, y: 16.22), control2: CGPoint(x: 26.81, y: 16.23))
    bezierPath.addCurve(to: CGPoint(x: 27.25, y: 14.26), control1: CGPoint(x: 27.64, y: 15.39), control2: CGPoint(x: 27.65, y: 14.7))
    return bezierPath
  }
}

public struct RefreshIcon: View {
  @Environment(\.colorScheme) var colorScheme
  
  public init() { }
  
  public var body: some View {
    let fillColor = colorScheme == .dark ? Color.white : .black
    return ZStack {
      ArrowFirstShape()
        .fill(fillColor)
      ArrowSecondShape()
        .fill(fillColor)
    }
    .frame(width: 28, height: 25, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
  }
}

struct RefreshIcon_Previews: PreviewProvider {
  static var previews: some View {
    RefreshIcon()
      .previewLayout(.sizeThatFits)
  }
}
