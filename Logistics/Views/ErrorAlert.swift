///
//  ErrorAlert.swift
//  Logistics
//
//  Created by rickb on 1/29/20.
//  Copyright © 2020 HyperTrack. All rights reserved.
//

import Foundation
import SwiftUI

extension View {

	func errorAlertOverlay() -> some View {
		self.modifier(ErrorOverlayModifier())
	}

	func errorAlert(_ error: Binding<Error?>) -> some View {
		let presentedError = error.wrappedValue
		let isPresented = Binding(get: {
			error.wrappedValue != nil
		}, set: { isPresenting in
			error.wrappedValue = isPresenting ? presentedError : nil
		})
		return alert(isPresented: isPresented) {
			Alert(title: (error.wrappedValue?.localizedDescription ?? "").text)
		}
	}
}

struct ErrorOverlayModifier: ViewModifier {

	func body(content: Content) -> some View {
		ErrorOverlay {
			content
		}
	}
}

struct ErrorOverlay<Content: View>: View {
	@State private var displayError: Error?

	let content: Content

	var body: some View {
		content
			.errorAlert($displayError)
			.environment(\.displayError, $displayError)
    }

	init(@ViewBuilder content: () -> Content) {
		self.content = content()
	}
}

struct DisplayErrorKey: EnvironmentKey {
	static let defaultValue: Binding<Error?> = Binding.constant(nil)
}

extension EnvironmentValues {

	var displayError: Binding<Error?> {
		get { self[DisplayErrorKey.self] }
		set { self[DisplayErrorKey.self] = newValue }
	}
}
