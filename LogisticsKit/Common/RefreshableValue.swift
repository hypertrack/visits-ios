//
//  RefreshableValue.swift
//  LogisticsKit
//
//  Created by rickb on 1/26/20.
//  Copyright © 2020 HyperTrack. All rights reserved.
//

import Combine
import Foundation

public class RefreshableValue<T>: ObservableObject {

	public enum Result<Success> {
		case uninitialized
		case loading
		case success(Success)
		case failure(Error)
	}

	@Published public private(set) var result: Result<T>
	public private(set) var currentValue: T?

	private let updateValue: () -> AnyPublisher<T, Error>

	public init(currentValue: T? = nil, _ updateValue: @escaping () -> AnyPublisher<T, Error>) {
		self.currentValue = currentValue
		self.updateValue = updateValue
		if let currentValue = currentValue {
			self.result = .success(currentValue)
		} else {
			self.result = .uninitialized
		}
	}

	@discardableResult
	public func refresh() -> Future<T, Error> {
		result = .loading
		return Future { promise in
			self.updateValue().handleEvents(receiveOutput: { value in
				self.currentValue = value
			}, receiveCompletion: { completion in
				switch completion {
				case .finished:
					self.result = .success(self.currentValue!) // swiftlint:disable:this force_unwrapping
					promise(.success(self.currentValue!)) // swiftlint:disable:this force_unwrapping
				case let .failure(error):
					self.result = .failure(error)
					promise(.failure(error))
				}
			})
			.untilCompletion()
		}
	}

	public func set(_ value: T) {
		currentValue = value
		result = .success(value)
	}
}

public extension RefreshableValue.Result {

	var isUninitialized: Bool {
		if case .uninitialized = self {
			return true
		} else {
			return false
		}
	}

	var isLoading: Bool {
		if case .loading = self {
			return true
		} else {
			return false
		}
	}

	var value: Success? {
		if case let .success(value) = self {
			return value
		} else {
			return nil
		}
	}

	var error: Error? {
		if case let .failure(error) = self {
			return error
		} else {
			return nil
		}
	}
}
