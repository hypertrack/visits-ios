//
//  Configurable.swift
//  ExtraKit
//
//  Created by rickb on 4/18/16.
//  Copyright © 2018 rickbdotcom LLC. All rights reserved.
//

import Foundation

public protocol ConfigurableSelf {
}

public extension ConfigurableSelf where Self: AnyObject {

    @discardableResult func configure(_ block: (Self) -> Void) -> Self {
        block(self)
        return self
    }
}

public extension NSObjectProtocol {

	@discardableResult func configure(_ block: (Self) -> Void) -> Self {
		block(self)
		return self
	}
}

public func configure<T>(_ object: T, using closure: (inout T) -> Void) -> T {
    var object = object
    closure(&object)
    return object
}
