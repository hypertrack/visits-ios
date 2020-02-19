//
//  Preview.swift
//  Logistics
//
//  Created by rickb on 1/26/20.
//  Copyright © 2020 HyperTrack. All rights reserved.

import Foundation
import LogisticsKit
import SwiftUI

#if DEBUG
extension View {

	func previewEnvironment(error: Error? = nil, showingActivity: Bool = false) -> some View {
		self
		.errorAlertOverlay()
		.activityOverlay()
		.environmentObject(defaultTheme)
		.environmentObject(HypertrackLogisticsManager(service: LogisticsMockService()))
	}
}
#endif
