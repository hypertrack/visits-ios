//
//  Alert.swift
//  ViewsComponents
//
//  Created by Dmytro Shapovalov on 08.05.2020.
//  Copyright © 2020 HyperTrack. All rights reserved.
//

import Foundation
import SwiftUI
import Prelude

public struct DoneAlert: View {
  private let timer: Timer.TimerPublisher
  private let title: NonEmptyString
  private let visibilityInterval: Double
  @Environment(\.colorScheme) var colorScheme
  @Binding private var isShowing: Bool
  
  public init(title: NonEmptyString, visibilityInterval: Double, shows: Binding<Bool>) {
    self.title = title
    self.visibilityInterval = visibilityInterval
    self._isShowing = shows
    self.timer = Timer.publish(every: visibilityInterval, on: .main, in: .common)
    if self.isShowing {
      _ = self.timer.connect()
    }
  }
  
  public var body: some View {
    GeometryReader { geometry in
      ZStack {
        VStack {
          AnimatedIcon()
            .scaledToFit()
          Text(self.title.rawValue)
            .font(UIFont.Alert.titleFont.sui)
            .foregroundColor(self.colorScheme == .dark ? UIColor.AlertColor.dark.sui : UIColor.AlertColor.light.sui)
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
        UINotificationFeedbackGenerator().notificationOccurred(UINotificationFeedbackGenerator.FeedbackType.success)
      }
      .onReceive(self.timer) { _ in
        withAnimation {
          self.isShowing = false
        }
      }
    }
  }
}

struct AnimatedIcon: UIViewRepresentable {
  @Environment(\.colorScheme) var colorScheme
  func makeUIView(context: Context) -> AnimatedDoneIcon {
    let icon = AnimatedDoneIcon(fillColor: self.colorScheme == .dark ? UIColor.AlertColor.dark : UIColor.AlertColor.light)
    return icon
  }

  func updateUIView(_ uiView: AnimatedDoneIcon, context: Context) { }
}

struct Blur: UIViewRepresentable {
  @Environment(\.colorScheme) var colorScheme
  var style: UIBlurEffect.Style = .systemMaterial
  
  func makeUIView(context: Context) -> UIVisualEffectView {
    return UIVisualEffectView(effect: UIBlurEffect(style: colorScheme == .dark ? .dark : .extraLight))
  }
  
  func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
    uiView.effect = UIBlurEffect(style: style)
  }
}

class AnimatedDoneIcon: UIView {
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
    animatableLayer.strokeColor = self.fillColor.cgColor
    animatableLayer.lineWidth = 9
    animatableLayer.lineCap = .round
    animatableLayer.lineJoin = .round
    animatableLayer.strokeEnd = 0
    self.layer.addSublayer(animatableLayer)
    
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
      DoneAlert(title: "Hello world", visibilityInterval: 3, shows: .constant(true))
        .environment(\.colorScheme, .dark)
      DoneAlert(title: "Hello world", visibilityInterval: 3, shows: .constant(true))
        .environment(\.colorScheme, .light)
    }
  }
}

struct Viewer: View {
  @State var shown = false
  var body: some View {
    ZStack {
      Button(action: {
        self.shown.toggle()
      }) {
        Text("Show")
      }
      if self.shown {
        DoneAlert(title: "Hello world", visibilityInterval: 1, shows: self.$shown)
      }
    }
  }
}

struct Viewer_Previews: PreviewProvider {
  static var previews: some View {
    Viewer()
  }
}
