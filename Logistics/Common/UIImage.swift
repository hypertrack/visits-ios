//
//  UIImage.swift
//  Logistics
//
//  Created by rickb on 2/2/20.
//  Copyright © 2020 HyperTrack. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {

	func fit(to size: CGSize, aspect: CGSize.AspectMode) -> UIImage? {
		resized(to: self.size.aspect(aspect, in: size))
	}

	func resized(to size: CGSize) -> UIImage? {
		let format = UIGraphicsImageRendererFormat()
		format.scale = 1.0

		let renderer = UIGraphicsImageRenderer(size: size, format: format)
		return renderer.image { _ in
			self.draw(in: CGRect(origin: .zero, size: size))
		}
	}
}
