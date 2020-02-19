//
//  Delivery.swift
//  Logistics
//
//  Created by rickb on 1/25/20.
//  Copyright © 2020 HyperTrack. All rights reserved.
//

import Foundation

public struct Delivery: Decodable, Identifiable {

	public var id: String { deliveryId }

	public let deliveryId: String
	public let driverId: String
	public let address: Address?
	public let status: Status
	public let label: String
	public let items: [Item]?
	public let createdAt: Date?
	public let updatedAt: Date?
	public let deliveryNote: String?
	public let deliveryPicture: String?
	public let customerNote: String?
	public let enteredAt: Date?
	public let exitedAt: Date?
	public let completedAt: Date?

	public enum Status: String, Decodable {
		case pending, completed, visited
	}

	public struct Address: Decodable {
		public let street: String?
		public let postalCode: String?
		public let city: String?
		public let state: String?
		public let country: String?
	}

	public struct Item: Decodable {
		public let itemId: String
		public let itemLabel: String?
		public let itemSku: String?

		enum CodingKeys: String, CodingKey {
			case itemId = "item_id"
			case itemLabel = "item_label"
			case itemSku = "item_sku"
		}
	}

	// can't use keyEncodingStrategy because API usage isn't consistent
	enum CodingKeys: String, CodingKey {
		case deliveryId = "delivery_id"
		case driverId = "driver_id"
		case address
		case status
		case label
		case items
		case createdAt
		case updatedAt
		case deliveryNote
		case deliveryPicture
		case customerNote
		case enteredAt
		case exitedAt
		case completedAt
	}
}
