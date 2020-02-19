//
//  Style.swift
//  Logistics
//
//  Created by rickb on 1/25/20.
//  Copyright © 2020 HyperTrack. All rights reserved.
//

import Foundation
import SwiftUI

/// View modifier used to apply application specific styling

struct Style: ViewModifier {

	enum Style {
		case title
		case body
		case placeholder
		case primaryButton
		case itemTitle
		case itemSubtitle
		case itemHeader
		case lightCaption
		case headline
	}

	let style: Style
	let theme: Theme

	init(_ style: Style, _ theme: Theme) {
		self.style = style
		self.theme = theme
	}

	func body(content: Content) -> some View {
		switch style {
		case .headline:
			return content
				.font(theme.fonts.headline)
				.foregroundColor(theme.text.primary.sui)
		case .title:
			return content
				.font(theme.fonts.title)
				.foregroundColor(theme.text.primary.sui)
		case .body:
			return content
				.font(theme.fonts.body)
				.foregroundColor(theme.text.primary.sui)
		case .placeholder:
			return content
				.font(theme.fonts.body)
				.foregroundColor(theme.text.tertiary.sui)
		case .primaryButton:
			return content
				.font(theme.fonts.body)
				.foregroundColor(theme.text.secondary.sui)
		case .itemTitle:
			return content
				.font(theme.fonts.itemTitle)
				.foregroundColor(theme.text.primary.sui)
		case .itemSubtitle:
			return content
				.font(theme.fonts.itemSubtitle)
				.foregroundColor(theme.text.tertiary.sui)
		case .itemHeader:
			return content
				.font(theme.fonts.body)
				.foregroundColor(theme.text.tertiary.sui)
		case .lightCaption:
			return content
				.font(theme.fonts.caption)
				.foregroundColor(theme.text.secondary.sui)
		}
    }
}
