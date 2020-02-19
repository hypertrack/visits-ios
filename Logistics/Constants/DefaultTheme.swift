//
//  DefaultTheme.swift
//  Logistics
//
//  Created by rickb on 1/25/20.
//  Copyright © 2020 HyperTrack. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

let defaultTheme = Theme(
	background: .init(
		primary: .white ,
		secondary: Assets.gray244.color,
		tracking: Assets.lochmara.color,
		visit: Assets.oldGold.color,
		complete: Assets.malachite.color,
		error: .red
	),
	text: .init (
		primary: .black,
		secondary: .white,
		tertiary: Assets.gray155.color
	),
	fonts: .init(
		title: Font.title.weight(.heavy),
		body: Font.body.weight(.heavy),
		subtitle: Font.subheadline.weight(.heavy),
		itemTitle: Font.body,
		itemSubtitle: Font.subheadline,
		caption: Font.caption,
		headline: Font.system(size: 25.0, weight: .heavy)
	)
)
