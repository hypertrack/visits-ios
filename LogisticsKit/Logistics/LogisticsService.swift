//
//  LogisticsService.swift
//  Logistics
//
//  Created by rickb on 1/26/20.
//  Copyright © 2020 HyperTrack. All rights reserved.
//

import Combine
import Foundation

public protocol LogisticsService {

	func getDrivers() -> AnyPublisher<[Driver], Error>
	func checkIn(driverId: String, token: String, appName: String, platform: String, deviceId: String) -> AnyPublisher<Driver, Error>
	func checkOut(driverId: String) -> AnyPublisher<Driver, Error>
	func driver(with driverId: String) -> AnyPublisher<Driver, Error>
	func delivery(with deliveryId: String) -> AnyPublisher<Delivery, Error>
	func markDeliveryAsCompleted(with deliveryId: String) -> AnyPublisher<Delivery, Error>
	func updateDelivery(with deliveryId: String, note: String?, picture: String?) -> AnyPublisher<Delivery, Error>
	func uploadDelivery(imageData: Data, contentType: String, with deliveryid: String) -> AnyPublisher<Delivery, Error>
}
