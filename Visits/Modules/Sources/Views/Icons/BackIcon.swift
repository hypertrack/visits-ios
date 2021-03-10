import SwiftUI
import Foundation

struct ArrowShape: Shape {
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

public struct BackIcon: View {
  @Environment(\.colorScheme) var colorScheme
  
  public init() {}
  
  public var body: some View {
    ZStack {
      ArrowShape()
        .fill(colorScheme == .dark ? Color.white : .black)
        .frame(width: 14, height: 22, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
    }
  }
}

struct BackIcon_Previews: PreviewProvider {
  static var previews: some View {
    BackIcon()
      .previewLayout(.sizeThatFits)
  }
}
