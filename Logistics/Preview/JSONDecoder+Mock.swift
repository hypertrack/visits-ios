//
//  JSONDecoder+Mock.swift
//  Logistics
//
//  Created by rickb on 2/1/20.
//  Copyright © 2020 HyperTrack. All rights reserved.
// swiftlint:disable force_try force_unwrapping

import Combine
import Foundation
import LogisticsKit

/// JSONDecoder extensions to mock data for SwiftUI previews

extension JSONDecoder {

    func decode<T: Decodable>(json: String) -> T {
		decode(T.self, json: json)
	}

    func decode<T: Decodable>(_ type: T.Type, json: String) -> T {
		try! decode(type, from: json.data(using: .utf8) ?? Data())
	}

	func decode<T: Decodable>(name: String) -> T {
		decode(T.self, name: name)
	}

	func decode<T: Decodable>(_ type: T.Type, name: String) -> T {
		let data = try! Data(contentsOf: Bundle.main.url(forResource: name, withExtension: "json")!)
		return try! decode(type, from: data)
	}

	func decodeToRefreshable<T: Decodable>(json: String) -> RefreshableValue<T> {
		decodeToRefreshable(T.self, json: json)
	}

	func decodeToRefreshable<T: Decodable>(_ type: T.Type, json: String) -> RefreshableValue<T> {
		let value = self.decode(T.self, json: json)
		return RefreshableValue(currentValue: value) { Result.Publisher(value).eraseToAnyPublisher() }
	}

	func decodeToRefreshable<T: Decodable>(name: String) -> RefreshableValue<T> {
		decodeToRefreshable(T.self, name: name)
	}

	func decodeToRefreshable<T: Decodable>(_ type: T.Type, name: String) -> RefreshableValue<T> {
		let value = self.decode(T.self, name: name)
		return RefreshableValue(currentValue: value) { Result.Publisher(value).eraseToAnyPublisher() }
	}

    func decodeToPublisher<T: Decodable>(json: String) -> AnyPublisher<T, Error> {
		decodeToPublisher(T.self, json: json)
	}

    func decodeToPublisher<T: Decodable>(_ type: T.Type, json: String) -> AnyPublisher<T, Error> {
		Result.Publisher(JSONDecoder.logisticsAPI.decode(json: json)).eraseToAnyPublisher()
	}

    func decodeToPublisher<T: Decodable>(name: String) -> AnyPublisher<T, Error> {
		decodeToPublisher(T.self, name: name)
	}

    func decodeToPublisher<T: Decodable>(_ type: T.Type, name: String) -> AnyPublisher<T, Error> {
		Result.Publisher(JSONDecoder.logisticsAPI.decode(name: name)).eraseToAnyPublisher()
	}
}
