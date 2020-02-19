//
//  LogisticsManager.swift
//  LogisticsKit
//
//  Created by rickb on 1/26/20.
//  Copyright © 2020 HyperTrack. All rights reserved.
//

import Combine
import Foundation
import UIKit

open class LogisticsManager: ObservableObject {

	private let allDriversValue: RefreshableValue<[Driver]>
	private var drivers = [String: RefreshableValue<Driver>]()
	private var deliveries = [String: RefreshableValue<Delivery>]()

	private let service: LogisticsService
	private var token = ""
	
	public init(service: LogisticsService) {
		allDriversValue = RefreshableValue {
			service.getDrivers()
		}
		self.service = service
	}

	public func setToken(_ token: Data) {
		self.token = token.reduce("") { $0 + String(format: "%02.2hhx", $1) }
	}

	public func checkin(driverId: String, deviceId: String) -> AnyPublisher<Driver, Error> {
		let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String ?? ""
		let platform = "ios"
		return service.checkIn(driverId: driverId, token: token, appName: appName, platform: platform, deviceId: deviceId)
	}

	public func checkout(driverId: String) -> AnyPublisher<Driver, Error> {
		if let driver = drivers[driverId] {
			(driver.currentValue?.deliveries ?? []).forEach {
				deliveries[$0.id] = nil
			}
			drivers[driverId] = nil
		}
		return service.checkOut(driverId: driverId)
	}

	public func allDrivers() -> RefreshableValue<[Driver]> {
		if allDriversValue.currentValue == nil {
			allDriversValue.refresh().untilCompletion()
		}
		
		return allDriversValue
	}

	public func driver(with driverId: String, initialValue: Driver? = nil) -> RefreshableValue<Driver> {
		if let driver = drivers[driverId] {
			return driver
		} else {
			let service = self.service
			let driver = RefreshableValue(currentValue: initialValue) {
				service.driver(with: driverId)
			}
			if initialValue == nil {
				driver.refresh().untilCompletion()
			}
			drivers[driverId] = driver
			return driver
		}
	}

	public func delivery(with deliveryId: String, initialValue: Delivery? = nil) -> RefreshableValue<Delivery> {
		if let delivery = deliveries[deliveryId] {
			return delivery
		} else {
			let service = self.service
			let delivery = RefreshableValue(currentValue: initialValue) {
				service.delivery(with: deliveryId)
			}
			if initialValue == nil {
				delivery.refresh().untilCompletion()
			}
			deliveries[deliveryId] = delivery
			return delivery
		}
	}

	public func markDeliveryAsCompleted(with deliveryId: String) -> AnyPublisher<Delivery, Error> {
		service.markDeliveryAsCompleted(with: deliveryId).handleEvents(receiveOutput: { delivery in
			self.deliveryUpdated(delivery)
		}).eraseToAnyPublisher()
	}

	public func updateDelivery(with deliveryId: String, note: String? = nil, picture: String?) -> AnyPublisher<Delivery, Error> {
		service.updateDelivery(with: deliveryId, note: note, picture: picture).handleEvents(receiveOutput: { delivery in
			self.deliveryUpdated(delivery)
		}).eraseToAnyPublisher()
	}

	public func uploadDelivery(image: UIImage, with deliveryId: String) -> AnyPublisher<Delivery, Error> {
		let data = image.jpegData(compressionQuality: 1) ?? Data()
		return service.uploadDelivery(imageData: data, contentType: "image/jpeg", with: deliveryId).handleEvents(receiveOutput: { delivery in
			self.deliveryUpdated(delivery)
		}).eraseToAnyPublisher()
	}

	public func refreshAll() {
		allDriversValue.refresh()
		drivers.values.forEach { $0.refresh() }
		deliveries.values.forEach { $0.refresh() }
	}
}

private extension LogisticsManager {
	private func deliveryUpdated(_ delivery: Delivery) {
		self.delivery(with: delivery.id, initialValue: delivery).set(delivery)
		self.driver(with: delivery.driverId).refresh().untilCompletion()
	}
}
