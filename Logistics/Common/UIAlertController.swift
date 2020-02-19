//
//  UIAlertController.swift
//  ExtraKit
//
//  Created by rickb on 4/18/16.
//  Copyright © 2018 rickbdotcom LLC. All rights reserved.
//

import UIKit

public extension UIAlertController {

	class func alert(title: String? = nil, message: String? = nil) -> UIAlertController {
		UIAlertController(title: title, message: message, preferredStyle: .alert)
	}

	class func actionSheet(from source: Any, title: String? = nil, message: String? = nil) -> UIAlertController {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
		if let presenter = alert.popoverPresentationController {
			if let sourceView = source as? UIView {
				presenter.sourceView = sourceView
				presenter.sourceRect = sourceView.bounds
			} else if let barButtonItem = source as? UIBarButtonItem {
				presenter.barButtonItem = barButtonItem
			}
		}
		return alert
	}

	@discardableResult
	func ok(_ style: UIAlertAction.Style = .default, preferred: Bool = false, action inAction: ((UIAlertController) -> Void)? = nil) -> Self {
		action(title: NSLocalizedString("OK", comment: ""), style: style, preferred: preferred, action: inAction) // swiftlint:disable:this swiftgen_strings
	}

	@discardableResult
	func cancel(_ style: UIAlertAction.Style = .cancel, preferred: Bool = false, inAction: ((UIAlertController) -> Void)? = nil) -> Self {
		action(title: NSLocalizedString("Cancel", comment: ""), style: style, preferred: preferred, action: inAction) // swiftlint:disable:this swiftgen_strings
	}

	@discardableResult
	func action(title: String?, style: UIAlertAction.Style = .default, preferred: Bool = false, action: ((UIAlertController) -> Void)? = nil) -> Self {
		let action = UIAlertAction(title: title, style: style) { [weak self] _ in
			if let alert = self {
				action?(alert)
			}
		}
		addAction(action)
		if preferred == true {
			preferredAction = action
		}
		return self
	}

	@discardableResult
	func textField(configurationHandler: ((UITextField) -> Void)? = nil) -> Self {
		addTextField(configurationHandler: configurationHandler)
		return self
	}

	@discardableResult
	func show(in viewController: UIViewController?, animated: Bool = true, completion: (() -> Void)? = nil) -> Self {
		viewController?.present(self, animated: animated, completion: completion)
		return self
	}
}
