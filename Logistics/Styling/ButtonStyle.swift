//
//  ButtonStyle.swift
//  Logistics
//
//  Created by rickb on 1/25/20.
//  Copyright © 2020 HyperTrack. All rights reserved.
//

import Foundation
import SwiftUI

/// Application specific button styles

struct ButtonStyle: SwiftUI.ButtonStyle {

	enum Style {
		case primary
		case picker
		case secondary
	}

	let style: Style
	let theme: Theme
	let isEnabled: Bool

	init(_ style: Style, _ theme: Theme, isEnabled: Bool = true) {
		self.style = style
		self.theme = theme
		self.isEnabled = isEnabled
	}

    func makeBody(configuration: Self.Configuration) -> some View {
		switch style {
		case .primary:
			return configuration.label
				.frame(height: 60)
				.frame(maxWidth: .infinity)
				.background(isEnabled ? theme.text.primary.sui : theme.text.tertiary.sui)
				.any
		case .secondary:
			return configuration.label
				.frame(height: 60)
				.frame(maxWidth: .infinity)
				.background(theme.text.tertiary.sui)
				.any
		case .picker:
			return configuration.label
				.frame(height: 60)
				.frame(maxWidth: .infinity)
				.border(theme.text.tertiary.sui, width: 1)
				.any
		}
    }
}
