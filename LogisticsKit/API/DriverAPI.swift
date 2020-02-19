//
//  DriverAPI.swift
//  Logistics
//
//  Created by rickb on 1/25/20.
//  Copyright © 2020 HyperTrack. All rights reserved.
//

import Foundation

enum DriverAPI {

	struct List: APIRequest {
		typealias Response = [Driver]

		let parameters: NoParameters
		var endpoint: Endpoint { .init("drivers", .get) }
	}

	struct Get: APIRequest {
		typealias Response = Driver

		let id: String
		let parameters: NoParameters
		var endpoint: Endpoint { .init("drivers/\(id)", .get) }
	}

	struct CheckIn: APIRequest {
		struct Parameters: Encodable {
			let device_id: String
			let token: String
			let app_name: String
			let platform: String
		}
		typealias Response = Driver

		let id: String
		let parameters: Parameters
		var endpoint: Endpoint { .init("drivers/\(id)/checkin", .post) }
	}

	struct CheckOut: APIRequest {
		typealias Response = Driver

		let id: String
		let parameters: NoParameters
		var endpoint: Endpoint { .init("drivers/\(id)/checkout", .post) }
	}
}
