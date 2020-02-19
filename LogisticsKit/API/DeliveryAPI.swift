//
//  DeliveryAPI.swift
//  Logistics
//
//  Created by rickb on 1/25/20.
//  Copyright © 2020 HyperTrack. All rights reserved.
//

import Foundation

enum DeliveryAPI {

	struct List: APIRequest {
		typealias Response = [Delivery]

		let parameters: NoParameters
		var endpoint: Endpoint { .init("deliveries", .get) }
	}

	struct Get: APIRequest {
		typealias Response = Delivery

		let id: String
		let parameters: NoParameters
		var endpoint: Endpoint { .init("deliveries/\(id)", .get) }
	}

	struct Update: APIRequest {
		struct Parameters: Encodable {
			let deliveryNote: String?
			let deliveryPicture: String?
		}
		typealias Response = Delivery

		let id: String
		let parameters: Parameters
		var endpoint: Endpoint { .init("deliveries/\(id)", .patch) }
	}

	struct Complete: APIRequest {
		typealias Response = Delivery

		let id: String
		let parameters: NoParameters
		var endpoint: Endpoint { .init("deliveries/\(id)/complete", .get) }
	}

	struct UploadImage: APIRequest {
		typealias Response = Delivery

		let id: String
		let parameters: NoParameters
		var endpoint: Endpoint { .init("deliveries/\(id)/image", .post) }
	}
}
