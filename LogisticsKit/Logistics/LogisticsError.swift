//
//  LogisticsError.swift
//  Logistics
//
//  Created by rickb on 1/25/20.
//  Copyright © 2020 HyperTrack. All rights reserved.
//

import Foundation

public enum LogisticsError: LocalizedError {

	case noResponse
	case api(Int, String)
	case apiHTML(Int, String)

	public var errorDescription: String? {
		switch self {
		case .noResponse:
			return "No Response"
		case let .api(code, message):
			return "HTTP Error \(code)\n\(message)"
		case let .apiHTML(_, html):
			return html
		}
	}

	public init?(response: URLResponse?, data: Data, decoder: JSONDecoder) {
		guard let response = response as? HTTPURLResponse else {
			self = .noResponse
			return
		}
		if 200..<300 ~= response.statusCode {
			return nil
		}
		do {
			let apiError = try decoder.decode(APIErrorResponse.self, from: data)
			self = .api(response.statusCode, apiError.message)
		} catch {
			let statusCode = response.statusCode
			let string = String(data: data, encoding: .utf8) ?? ""
			if (response.allHeaderFields["Content-Type"] as? String)?.contains("text/html") == true {
				self = .apiHTML(statusCode, string)
			} else {
				self = .api(statusCode, string)
			}
		}
	}
}

struct APIErrorResponse: Decodable {
	let message: String
}
