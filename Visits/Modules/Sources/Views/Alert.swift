import Foundation
import SwiftUI

public struct DoneAlert: View {
  private let timer: Timer.TimerPublisher
  private let title: String
  private let duration: Double
  @Environment(\.colorScheme) private var colorScheme
  @Binding private var visible: Bool
  
  public init(title: String, duration: Double, visible: Binding<Bool>) {
    self.title = title
    self.duration = duration
    self._visible = visible
    self.timer = Timer.publish(every: duration, on: .main, in: .common)
    if self.visible {
      _ = self.timer.connect()
    }
  }
  
  public var body: some View {
    GeometryReader { geometry in
      ZStack {
        VStack {
          AnimatedIcon()
            .scaledToFit()
          Text(title)
            .font(.largeBold)
            .foregroundColor(colorScheme == .dark ? .gunPowder : .saltBox)
            .multilineTextAlignment(.center)
            .lineLimit(2)
          Spacer()
        }
      }
      .frame(
        width: geometry.size.width / 2,
        height: geometry.size.width / 2
      )
      .background(Blur())
      .cornerRadius(10)
      .shadow(radius: 5)
      .onAppear {
        UINotificationFeedbackGenerator()
          .notificationOccurred(.success)
      }
      .onReceive(timer) { _ in
        withAnimation {
          visible = false
        }
      }
    }
  }
}

private struct AnimatedIcon: UIViewRepresentable {
  @Environment(\.colorScheme) var colorScheme
  
  func makeUIView(context: Context) -> AnimatedDoneIcon {
    AnimatedDoneIcon(fillColor: colorScheme == .dark ? .gunPowder : .saltBox)
  }

  func updateUIView(_ uiView: AnimatedDoneIcon, context: Context) { }
}

private struct Blur: UIViewRepresentable {
  @Environment(\.colorScheme) var colorScheme
  var style: UIBlurEffect.Style = .systemMaterial
  
  func makeUIView(context: Context) -> UIVisualEffectView {
    UIVisualEffectView(effect: UIBlurEffect(style: colorScheme == .dark ? .dark : .extraLight))
  }
  
  func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
    uiView.effect = UIBlurEffect(style: style)
  }
}

private class AnimatedDoneIcon: UIView {
  let fillColor: UIColor
  
  init(fillColor: UIColor) {
    self.fillColor = fillColor
    super.init(frame: CGRect.zero)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func draw(_ rect: CGRect) {
    let length = frame.width
    let animatablePath = UIBezierPath()
    animatablePath.move(to: CGPoint(x: length * 0.196, y: length * 0.527))
    animatablePath.addLine(to: CGPoint(x: length * 0.47, y: length * 0.777))
    animatablePath.addLine(to: CGPoint(x: length * 0.99, y: length * 0.25))
    
    let animatableLayer = CAShapeLayer()
    animatableLayer.path = animatablePath.cgPath
    animatableLayer.fillColor = UIColor.clear.cgColor
    animatableLayer.strokeColor = fillColor.cgColor
    animatableLayer.lineWidth = 9
    animatableLayer.lineCap = .round
    animatableLayer.lineJoin = .round
    animatableLayer.strokeEnd = 0
    layer.addSublayer(animatableLayer)
    
    let animation = CABasicAnimation(keyPath: "strokeEnd")
    animation.duration = 0.3
    animation.fromValue = 0
    animation.toValue = 1
    animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    animatableLayer.strokeEnd = 1
    animatableLayer.add(animation, forKey: "animation")
  }
}

struct Alert_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      DoneAlert(title: "Hello world", duration: 3, visible: .constant(true))
        .previewScheme(.light)
      DoneAlert(title: "Hello world", duration: 3, visible: .constant(true))
        .previewScheme(.dark)
    }
    .previewLayout(.sizeThatFits)
  }
}

private struct Viewer: View {
  @State var visible = false
  var body: some View {
    ZStack {
      Button {
        visible.toggle()
      } label: {
        Text("Show")
      }
      if visible {
        DoneAlert(title: "Hello world", duration: 1, visible: $visible)
      }
    }
  }
}

struct Viewer_Previews: PreviewProvider {
  static var previews: some View {
    Viewer()
      .previewLayout(.sizeThatFits)
  }
}
