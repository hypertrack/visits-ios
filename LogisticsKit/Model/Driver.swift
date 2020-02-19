//
//  Driver.swift
//  Logistics
//
//  Created by rickb on 1/25/20.
//  Copyright © 2020 HyperTrack. All rights reserved.
//

import Foundation

public struct Driver: Decodable {

	public var id: String { driverId }

	public let driverId: String
	public let deliveries: [Delivery]?
	public let name: String?
	public let deviceId: String?
	public let token: String?
	public let createdAt: Date?
	public let updatedAt: Date?
	public let activeTrip: String?
	public let appName: String?
	public let platform: String?

// can't use keyEncodingStrategy because API usage isn't consistent
	enum CodingKeys: String, CodingKey {
		case driverId = "driver_id"
		case deliveries
		case name
		case deviceId = "device_id"
		case token
		case createdAt
		case updatedAt
		case activeTrip = "active_trip"
		case appName = "app_name"
		case platform
	}
}
