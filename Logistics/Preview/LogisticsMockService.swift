//
//  LogisticsMockService.swift
//  Logistics
//
//  Created by rickb on 1/26/20.
//  Copyright © 2020 HyperTrack. All rights reserved.
//

import Combine
import Foundation
import LogisticsKit

/// mock Logistics service for use in SwiftUI previews or local mocking

class LogisticsMockService: LogisticsService {

	func getDrivers() -> AnyPublisher<[Driver], Error> {
		JSONDecoder.logisticsAPI.decodeToPublisher(name: "all_drivers")
	}

	func checkIn(driverId: String, token: String, appName: String, platform: String, deviceId: String) -> AnyPublisher<Driver, Error> {
		JSONDecoder.logisticsAPI.decodeToPublisher(name: "driver")
	}

	func checkOut(driverId: String) -> AnyPublisher<Driver, Error> {
		JSONDecoder.logisticsAPI.decodeToPublisher(name: "driver")
	}

	func driver(with driverId: String) -> AnyPublisher<Driver, Error> {
		JSONDecoder.logisticsAPI.decodeToPublisher(name: "driver")
	}

	func delivery(with deliveryId: String) -> AnyPublisher<Delivery, Error> {
		JSONDecoder.logisticsAPI.decodeToPublisher(name: "delivery")
	}

	func markDeliveryAsCompleted(with deliveryId: String) -> AnyPublisher<Delivery, Error> {
		JSONDecoder.logisticsAPI.decodeToPublisher(name: "delivery")
	}

	func updateDelivery(with deliveryId: String, note: String?, picture: String?) -> AnyPublisher<Delivery, Error> {
		JSONDecoder.logisticsAPI.decodeToPublisher(name: "delivery")
	}

	func uploadDelivery(imageData: Data, contentType: String, with deliveryid: String) -> AnyPublisher<Delivery, Error> {
		JSONDecoder.logisticsAPI.decodeToPublisher(name: "delivery")
	}
}
