//
//  String.swift
//  ExtraKit
//
//  Created by rickb on 4/18/16.
//  Copyright © 2018 rickbdotcom LLC. All rights reserved.
//

import Foundation

public extension String {

/// Returns nil is string is empty
    var emptyNil: String? {
        isEmpty ? nil : self
    }
}

public extension Sequence where Element == String {

	/// Joins array of strings, filtering out any empty ones
    func emptyJoined(separator: String) -> String {
        map { $0.emptyNil }.emptyJoined(separator: separator)
    }

	/// Joins array of strings, filtering out any empty ones and returning nil if resulting string is empty
    func emptyJoined(separator: String) -> String? {
        emptyJoined(separator: separator).emptyNil
    }
}

public extension Sequence where Element == String? {

	/// Joins array of optional strings, filtering out any empty ones
    func emptyJoined(separator: String) -> String {
        compactMap { $0 }.joined(separator: separator)
    }

	/// Joins array of optional strings, filtering out any empty ones and returning nil if resulting string is empty
    func emptyJoined(separator: String) -> String? {
        emptyJoined(separator: separator).emptyNil
    }
}

public extension Optional where Wrapped == String {

/// Evaluates to empty if wrapped string or Optional itself is nil
    var isEmpty: Bool {
        (self ?? "").isEmpty
    }
}
