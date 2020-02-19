//
//  LogisticsManager.swift
//  Logistics
//
//  Created by rickb on 1/26/20.
//  Copyright © 2020 HyperTrack. All rights reserved.
//

import Combine
import Foundation
import GoogleMaps
import HyperTrack
import LogisticsKit
import SwiftUI

class HypertrackLogisticsManager: LogisticsManager {

	/// Instance of logistics manager used by the application
	static let shared: HypertrackLogisticsManager = {
		GMSServices.provideAPIKey(googleMapsApiKey)
		
		// initialize the Logistics Service used by the manager
		var session = URLSession.shared
		// configure various environment variables that can be used for debugging
		if ProcessInfo.processInfo.environment["disableCache"] != nil {
			// clear URL cache
			let config = URLSessionConfiguration.default
			config.requestCachePolicy = .reloadIgnoringLocalCacheData
			config.urlCache = nil
			session = URLSession(configuration: config)
		}
		if ProcessInfo.processInfo.environment["useMocks"] != nil {
			// use mock api service instead
			return HypertrackLogisticsManager(service: LogisticsMockService())
		} else {
			let service = LogisticsAPIService(baseURL: logisticsApiURL, session: session)
			return HypertrackLogisticsManager(service: service)
		}
	}()

	@Published var isRunning = false

	private var hyperTrack: HyperTrack! // swiftlint:disable:this implicitly_unwrapped_optional

/// initializes Hypertrack SDK
	private func startHypertrack() {
		let key = HyperTrack.PublishableKey(hypertrackKey)! // swiftlint:disable:this force_unwrapping
		switch HyperTrack.makeSDK(publishableKey: key) {
		case let .success(hypertrack):
			hyperTrack = hypertrack
		case let .failure(error):
			print(error)
		}

		isRunning = hyperTrack.isRunning

		// observe tracking notifications from Hypertrack in order to update isRunning variable
		NotificationCenter.default.addObserver(self, selector: #selector(trackingChanged), name: HyperTrack.startedTrackingNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(trackingChanged), name: HyperTrack.stoppedTrackingNotification, object: nil)

		// observe signifcant time change notification so we can refresh all data daily
		NotificationCenter.default.addObserver(self, selector: #selector(significantTimeChange), name: UIApplication.significantTimeChangeNotification, object: nil)
	}

	/// Performs permissions check before calling /checkin endpoint
	func appCheckin(with driverId: String) -> AnyPublisher<Driver, Error> {
		let permissions: [PermissionsManager.Permission] = [
			.notification([.sound, .badge, .alert]),
			.location(alwaysOn: true),
			.coreMotion
		]
		return Future<Void, Error> { promise in
			PermissionsManager.shared.requestAccess(permissions) { error in
				if let error = error {
					promise(.failure(error))
				} else {
					promise(.success(()))
				}
			}
		}.flatMap { _ -> AnyPublisher<Driver, Error> in
			self.startHypertrack()
			return self.checkin(driverId: driverId, deviceId: self.hyperTrack.deviceID)
		}.eraseToAnyPublisher()
	}

	/// Adds trip marker with Hypertrack in addition to marking delivery as complete
	func markDeliveryAsCompleted(_ delivery: Delivery) -> AnyPublisher<Delivery, Error> {
		markDeliveryAsCompleted(with: delivery.deliveryId).handleEvents(receiveOutput: { _ in
			var dict = [String: Any]()
			dict["deliveryId"] = delivery.deliveryId
			dict["deliveryStatus"] = "completed"
			dict["deliveryNote"] = delivery.deliveryNote?.emptyNil
			dict["deliveryPicture"] = delivery.deliveryPicture?.emptyNil
			if let metadata = HyperTrack.Metadata(dictionary: dict) {
				self.hyperTrack.addTripMarker(metadata)
			}
		}).eraseToAnyPublisher()
	}

	/// Call from didReceiveRemoteNotification appDelegate to refresh data from notification payload
	func didReceiveRemoteNotification(_ userInfo: [AnyHashable: Any]) {
		if let deliveryId = userInfo["delivery_id"] as? String {
			delivery(with: deliveryId).refresh().flatMap { delivery in
				self.driver(with: delivery.driverId).refresh()
			}.untilCompletion()

		}
	}
}

private extension HypertrackLogisticsManager {

	@objc
	func trackingChanged() {
		isRunning = hyperTrack.isRunning
	}

	@objc
	func significantTimeChange() {
		refreshAll()
	}
}
