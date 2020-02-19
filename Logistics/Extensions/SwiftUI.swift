//
//  SwiftUI.swift
//  Logistics
//
//  Created by rickb on 1/26/20.
//  Copyright © 2020 HyperTrack. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

// Collection of simple SwiftUI extensions to bridge from UIKit

extension UIImage {
	/// returns SwiftUI Image
	var sui: Image { Image(uiImage: self) }
}

extension UIColor {
	/// returns SwiftUI Color
	var sui: Color { Color(self) }
}

extension String {
	// returns SwiftUI Text
	var text: Text { Text(self) }
}

extension View {
	/// returns wrapped AnyView of self
	var any: AnyView { AnyView(self) }
}

extension Binding {

	/// Returns a binding to item at object's keyPath
	init<T: AnyObject>(_ object: T, _ keyPath: ReferenceWritableKeyPath<T, Value>) {
		self.init(get: { object[keyPath: keyPath] }, set: { object[keyPath: keyPath] = $0 })
	}
}
