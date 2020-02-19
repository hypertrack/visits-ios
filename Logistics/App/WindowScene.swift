//
//  WindowScene.swift
//  Logistics
//
//  Created by rickb on 1/30/20.
//  Copyright © 2020 HyperTrack. All rights reserved.
//

import Foundation
import LogisticsKit
import SwiftUI
import UIKit

extension UIWindowScene {

/// Initialize the application window with SwiftUI content
	func appWindow() -> UIWindow {
		let contentView =
			NavigationView {
				LoginView(drivers: HypertrackLogisticsManager.shared.allDrivers())
			}
			.errorAlertOverlay()
			.activityOverlay()
			.environmentObject(defaultTheme)
			.environmentObject(HypertrackLogisticsManager.shared)

		let window = UIWindow(windowScene: self)
		window.rootViewController = UIHostingController(rootView: contentView)
		window.makeKeyAndVisible()
		return window
	}
}
