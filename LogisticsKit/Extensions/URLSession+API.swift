//
//  APIEndpointRequest.swift
//  Logistics
//
//  Created by rickb on 1/25/20.
//  Copyright © 2020 HyperTrack. All rights reserved.
//

import Combine
import Foundation

extension URLSession {

	func request<T: APIRequest>(_ request: T, baseURL: URL, headers: [String: String]?, data: Data? = nil, contentType: String? = nil) -> AnyPublisher<T.Response, Error> {
		dataTaskPublisher(for: request.urlRequest(baseURL: baseURL, encoder: .logisticsAPI, headers: headers, data: data, contentType: contentType))
			.logisticsError(decoder: .logisticsAPI)
			.decode(type: T.Response.self, decoder: JSONDecoder.logisticsAPI)
			.receive(on: RunLoop.main)
			.eraseToAnyPublisher()
	}
}

extension URLSession.DataTaskPublisher {

	func logisticsError(decoder: JSONDecoder) -> AnyPublisher<Data, Error> {
		tryMap {
			let data = $0.data
			if let error = LogisticsError(response: $0.response, data: data, decoder: decoder) {
				throw error
			}
			return data
		}.eraseToAnyPublisher()
	}
}
