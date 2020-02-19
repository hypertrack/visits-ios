//
//  Publisher.swift
//  LogisticsKit
//
//  Created by rickb on 1/28/20.
//  Copyright © 2020 HyperTrack. All rights reserved.
//

import Combine
import Foundation

public extension Publisher {

	@discardableResult
	func untilCompletion(_ receiveValue: ((Output) -> Void)? = nil) -> Cancellable {
		subscribeUntilCompletion { done in
			self.sink(receiveCompletion: { _ in
				done()
			}, receiveValue: receiveValue ?? { _ in })
		}
	}
}

@discardableResult
public func subscribeUntilCompletion(_ block: @escaping (@escaping () -> Void) -> Cancellable) -> Cancellable {
	var subscription: Cancellable?
	subscription = block {
		if subscription != nil {
			subscription = nil
		}
	}
	return ExplicitCancellable {
		subscription?.cancel()
		subscription = nil
	}
}

private struct ExplicitCancellable: Cancellable {
	let cancelBlock: () -> Void

	func cancel() {
		cancelBlock()
	}
}
