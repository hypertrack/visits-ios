//
//  LogisticsAPIService.swift
//  Logistics
//
//  Created by rickb on 1/26/20.
//  Copyright © 2020 HyperTrack. All rights reserved.
//

import Combine
import Foundation

public struct LogisticsAPIService: LogisticsService {

	private let baseURL: URL
	private let session: URLSession
	private let headers: [String: String]?

	public init(baseURL: URL, session: URLSession, headers: [String: String]? = nil) {
		self.baseURL = baseURL
		self.session = session
		self.headers = headers
	}

	public func getDrivers() -> AnyPublisher<[Driver], Error> {
		session.request(DriverAPI.List(parameters: .none), baseURL: baseURL, headers: headers)
	}

	public func checkIn(driverId: String, token: String, appName: String, platform: String, deviceId: String) -> AnyPublisher<Driver, Error> {
		session.request(DriverAPI.CheckIn(id: driverId, parameters: .init(
			device_id: deviceId,
			token: token,
			app_name: appName,
			platform: platform
		)), baseURL: baseURL, headers: headers)
	}

	public func checkOut(driverId: String) -> AnyPublisher<Driver, Error> {
		session.request(DriverAPI.CheckOut(id: driverId, parameters: .none), baseURL: baseURL, headers: headers)
	}

	public func driver(with driverId: String) -> AnyPublisher<Driver, Error> {
		session.request(DriverAPI.Get(id: driverId, parameters: .none), baseURL: baseURL, headers: headers)
	}

	public func delivery(with deliveryId: String) -> AnyPublisher<Delivery, Error> {
		session.request(DeliveryAPI.Get(id: deliveryId, parameters: .none), baseURL: baseURL, headers: headers)
	}

	public func markDeliveryAsCompleted(with deliveryId: String) -> AnyPublisher<Delivery, Error> {
		session.request(DeliveryAPI.Complete(id: deliveryId, parameters: .none), baseURL: baseURL, headers: headers)
	}

	public func updateDelivery(with deliveryId: String, note: String? = nil, picture: String?) -> AnyPublisher<Delivery, Error> {
		session.request(DeliveryAPI.Update(id: deliveryId, parameters: .init(deliveryNote: note, deliveryPicture: picture)), baseURL: baseURL, headers: headers)
	}

	public func uploadDelivery(imageData: Data, contentType: String, with deliveryid: String) -> AnyPublisher<Delivery, Error> {
		session.request(DeliveryAPI.UploadImage(id: deliveryid, parameters: .none), baseURL: baseURL, headers: headers, data: imageData, contentType: contentType)
	}
}
