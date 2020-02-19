//
//  AssociatedValue.swift
//  ExtraKit
//
//  Created by rickb on 4/18/16.
//  Copyright © 2018 rickbdotcom LLC. All rights reserved.
//

import Foundation
import ObjectiveC

/***
// Example usage:
extension UILabel {
	@IBInspectable var lineHeight: Float {
		get { return associatedValue() ?? 0 }
		set { set(associatedValue: newValue) }
	}
}
**/

public extension NSObject {

	var associatedDictionary: NSMutableDictionary {
		objc_getAssociatedObject(self, &NSObject.associatedDictionaryKey) as? NSMutableDictionary ?? {
			let dict = NSMutableDictionary()
			objc_setAssociatedObject(self, &NSObject.associatedDictionaryKey, dict, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
			return dict
		}()
	}

	func associatedValue<T>(functionName: String? = #function, `default` defaultValue: @autoclosure () -> T) -> T {
		let key = associatedKey(for: functionName)
		if let value: T = associatedValue(forKey: key) {
			return value
		}
		let value = defaultValue()
		set(associatedValue: value, forKey: key)
		return value
	}
		
	func associatedValue<T>(functionName: String? = #function) -> T? {
		associatedValue(forKey: associatedKey(for: functionName))
	}

	func set(associatedValue value: Any?, functionName: String? = #function) {
		set(associatedValue: value, forKey: associatedKey(for: functionName))
	}
	
	func weakAssociatedValue<T>(functionName: String? = #function) -> T? {
		weakAssociatedValue(forKey: associatedKey(for: functionName))
	}
	
	func set(weakAssociatedValue value: AnyObject?, functionName: String? = #function) {
		set(weakAssociatedValue: value, forKey: associatedKey(for: functionName))
	}

	func associatedValue<T>(forKey key: String) -> T? {
		associatedDictionary[key] as? T
	}
	
	func set(associatedValue value: Any?, forKey key: String) {
		associatedDictionary[key] = value
	}

	func weakAssociatedValue<T>(forKey key: String) -> T? {
		(associatedDictionary[key] as? WeakObjectRef)?.object as? T
	}
	
	func set(weakAssociatedValue value: AnyObject?, forKey key: String) {
		associatedDictionary[key] = WeakObjectRef(value)
	}

	private func associatedKey(for functionName: String?) -> String {
		["com.extrakit", functionName].compactMap { $0 }.joined(separator: ".")
	}

	private static var associatedDictionaryKey = 0
}

private class WeakObjectRef: NSObject {
	weak var object: AnyObject?
	
	init?(_ object: AnyObject?) {
		guard let object = object else {
			return nil
		}
		self.object = object
	}
}
