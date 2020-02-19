//
//  UIKitScrollView.swift
//  Logistics
//
//  Created by rickb on 2/3/20.
//  Copyright © 2020 HyperTrack. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

/// Wrapping UIScrollView so we can take advantage of its functionality over SwiftUI scroll view to implement proper keyboard reveal behavior

struct UIKitScrollView<Content: View>: UIViewRepresentable {

	var content: Content

	init(@ViewBuilder content: () -> Content) {
		self.content = content()
	}

    func makeUIView(context: Context) -> UIScrollView {
		let scrollView = UIScrollView()
		scrollView.adjustContentInsetForKeyboardFrame = true
		scrollView.backgroundColor = .clear
		return scrollView
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {
		context.coordinator.hostingController?.view.removeFromSuperview()

		let hostingController = UIHostingController(rootView: content)
		uiView.addSubview(hostingController.view)
		hostingController.view.pin()
		hostingController.view.widthAnchor.constraint(equalTo: uiView.widthAnchor).isActive = true
		context.coordinator.hostingController = hostingController
	}

	func makeCoordinator() -> Coordinator {
		Coordinator()
	}

	class Coordinator {
		var hostingController: UIHostingController<Content>?
	}
}
