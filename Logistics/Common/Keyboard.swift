//
//  UIScrollView+Keyboard.swift
// 
//
//  Created by rickb on 4/18/16.
//  Copyright © 2018 rickbdotcom LLC. All rights reserved.
//

import UIKit

extension UIScrollView {

	@IBInspectable var adjustContentInsetForKeyboardFrame: Bool {
		set {
			if newValue {
				set(associatedValue: KeyboardNotificationObserver(scrollView: self))
			} else {
				set(associatedValue: nil)
			}
		}
		get {
			let value: KeyboardNotificationObserver? = associatedValue()
			return value != nil
		}
	}
}

class KeyboardNotificationObserver: NSObject {

	weak var scrollView: UIScrollView?
	var contentInset: UIEdgeInsets?
	var scrollIndicatorInsets: UIEdgeInsets?
	
	init(scrollView: UIScrollView) {
		super.init()

		self.scrollView = scrollView
		
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
	}
	
	@objc func keyboardWillChangeFrame(_ notification: Notification) {
		guard let scrollView = self.scrollView else {
			return
		}
		if contentInset == nil {
			contentInset = scrollView.contentInset
		}
		scrollView.contentInset.bottom = adjustedKeyboardFrameHeight(notification)

		scrollToVisibleResponder(notification)
	}

	@objc func keyboardWillHide(_ note: Notification) {
		guard let scrollView = self.scrollView else {
			return
		}
		if let contentInset = self.contentInset {
			scrollView.contentInset = contentInset
			self.contentInset = nil
		}
		if let scrollIndicatorInsets = self.scrollIndicatorInsets {
			scrollView.scrollIndicatorInsets = scrollIndicatorInsets
			self.scrollIndicatorInsets = nil
		}
	}

	func scrollToVisibleResponder(_ note: Notification) {
		guard let scrollView = scrollView,
		let window = scrollView.window,
		let keyboardFrame = note.keyboardFrameEnd,
		let revealView = scrollView.findFirstResponder() else { return }
		let frame = scrollView.convert(revealView.bounds, from: revealView) // this *should not* be necessary but for some inexplicable reason in SwiftUI frame is always the same as bounds (i.e. origin is .zero) WTF?

		if scrollView.convert(window.convert(keyboardFrame, from: nil), from: nil).intersects(frame) {
			scrollView.scrollRectToVisible(frame, animated: true)
		}
	}

	func adjustedKeyboardFrameHeight(_ note: Notification) -> CGFloat {
		guard let scrollView = scrollView, let keyboardFrame = note.keyboardFrameEnd else {
			return 0
		}
		
		var h = keyboardFrame.size.height
		let dh = UIScreen.main.bounds.size.height - scrollView.convert(scrollView.bounds, to: UIScreen.main.coordinateSpace).maxY
		if dh > 0 {
			h -= dh
		}
		if h < 0 {
			h = 0
		}
		return h
	}
}

public extension Notification {

	var keyboardFrameEnd: CGRect? {
		if let info = (self as Notification).userInfo, let value = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            return value.cgRectValue
        } else {
            return nil
        }
    }
}

class KeyboardHeightConstraint: NSLayoutConstraint {

	override func awakeFromNib() {
		super.awakeFromNib()
		setupNotifications()
	}

	override init() {
		super.init()
		setupNotifications()
	}

	private func setupNotifications() {
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
	}

	@objc func keyboardWillChangeFrame(_ notification: Notification) {
		if let keyboardFrame = notification.keyboardFrameEnd {
			constant = keyboardFrame.size.height
		}    
	}

	@objc func keyboardWillHide(_ note: Notification) {
		constant = 0
	}
}

extension UIView {

	func findFirstResponder() -> UIView? {
		if isFirstResponder {
			return self
		}
		for subview in subviews {
			if let responder = subview.findFirstResponder() {
				return responder
			}
		}
		return nil
	}
}
