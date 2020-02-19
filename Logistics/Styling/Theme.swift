//
//  Theme.swift
//  Logistics
//
//  Created by rickb on 1/25/20.
//  Copyright © 2020 HyperTrack. All rights reserved.
//

import Foundation
import SwiftUI

/// Contains all the application specific colors and fonts used by styling objects.

class Theme: ObservableObject {

	@Published var background: Background
	@Published var text: Text
	@Published var fonts: Fonts

	struct Background {
		let primary: UIColor
		let secondary: UIColor
		let tracking: UIColor
		let visit: UIColor
		let complete: UIColor
		let error: UIColor
	}

	struct Text {
		let primary: UIColor
		let secondary: UIColor
		let tertiary: UIColor
	}

	struct Fonts {
		let title: Font
		let body: Font
		let subtitle: Font
		let itemTitle: Font
		let itemSubtitle: Font
		let caption: Font
		let headline: Font
	}

	init(background: Background, text: Text, fonts: Fonts) {
		self.background = background
		self.text = text
		self.fonts = fonts
	}
}
