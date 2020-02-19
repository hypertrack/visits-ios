//
//  ActivityIndicator.swift
//  Logistics
//
//  Created by rickb on 1/27/20.
//  Copyright © 2020 HyperTrack. All rights reserved.
//

import Foundation
import SwiftUI

/// SwiftUI wrapper for UIActivityIndicatorView

struct ActivityIndicator: UIViewRepresentable {

	let style: UIActivityIndicatorView.Style
	let color: UIColor
	@Binding var animating: Bool

	func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
		UIActivityIndicatorView(style: style).configure {
			$0.color = color
			$0.hidesWhenStopped = true
		}
	}

	func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
		if animating {
			uiView.startAnimating()
		} else {
			uiView.stopAnimating()
		}
	}
}

extension View {

	func activityOverlay() -> some View {
		self.modifier(ActivityOverlayModifier())
	}

	func activity(animating: Binding<Bool>) -> some View {
		overlay(Group {
			if animating.wrappedValue {
				ActivityIndicator(style: .large, color: .white, animating: animating)
					.frame(maxWidth: .infinity, maxHeight: .infinity)
					.background(Color.black.opacity(0.30))
			} else {
				EmptyView()
			}
		}.edgesIgnoringSafeArea(.all))
	}
}

struct ActivityOverlayModifier: ViewModifier {

	func body(content: Content) -> some View {
		ActivityOverlay {
			content
		}
	}
}

struct ActivityOverlay<Content: View>: View {
	@State private var showingActivity: Bool = false

	let content: Content

	var body: some View {
		content
			.activity(animating: $showingActivity)
			.environment(\.showingActivity, $showingActivity)
    }

	init(@ViewBuilder content: () -> Content) {
		self.content = content()
	}
}

struct ActivityKey: EnvironmentKey {
	static let defaultValue = Binding.constant(false)
}

extension EnvironmentValues {

	var showingActivity: Binding<Bool> {
		get { self[ActivityKey.self] }
		set { self[ActivityKey.self] = newValue }
	}
}
