//
//  Codable.swift
//  LogisticsKit
//
//  Created by rickb on 1/26/20.
//  Copyright © 2020 HyperTrack. All rights reserved.
//

import Foundation

extension JSONDecoder: ConfigurableSelf { }
public extension JSONDecoder {

	static let logisticsAPI = JSONDecoder().configure {
//		$0.keyDecodingStrategy = .convertFromSnakeCase // unfortunately API isn't consistent here so we have to handle with CodingKeys
		$0.dateDecodingStrategy = .logisticsAPI
	}
}

extension JSONEncoder: ConfigurableSelf { }
public extension JSONEncoder {

	static let logisticsAPI = JSONEncoder().configure {
//		$0.keyEncodingStrategy = .convertToSnakeCase // unfortunately API isn't consistent here so we have to handle with CodingKeys
		$0.dateEncodingStrategy = .logisticsAPI
	}
}

public extension JSONDecoder.DateDecodingStrategy {

	static let logisticsAPI: Self = .custom { decoder -> Date in
        let container = try decoder.singleValueContainer()
        var string = try container.decode(String.self)

        if let date = iso8601dateFormatterFS.date(from: string) {
            return date
		}
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid Date: \(string)")
	}
}

public extension JSONEncoder.DateEncodingStrategy {

	static let logisticsAPI: Self = .custom { date, encoder in
		var container = encoder.singleValueContainer()
		try container.encode(iso8601dateFormatterFS.string(from: date))
	}
}

public let iso8601dateFormatterFS = ISO8601DateFormatter().configure {
    $0.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
}
