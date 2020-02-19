//
//  APIRequest.swift
//  Logistics
//
//  Created by rickb on 1/25/20.
//  Copyright © 2020 HyperTrack. All rights reserved.
//

import Foundation

protocol APIRequest {
	associatedtype Parameters: Encodable
	associatedtype Response: Decodable

	var parameters: Parameters { get }
	var endpoint: Endpoint { get }
}

struct Endpoint {
	let path: String
	let method: HTTPMethod

	init(_ path: String, _ method: HTTPMethod) {
		self.path = path
		self.method = method
	}
}

extension APIRequest {

	func urlRequest(baseURL: URL, encoder: JSONEncoder, headers: [String: String]?, data: Data? = nil, contentType: String? = nil) -> URLRequest {
		var httpHeaders = headers ?? [:]
		var request = URLRequest(url: baseURL.appendingPathComponent(endpoint.path))
		request.httpMethod = endpoint.method.rawValue
	// Would need to handle url parameter encoding for GET if we ever need it.
	// I really need to actually write a general parameter encoding implementation at some point.
	// I always depended on Alamofire's parameter encoding functionality.
		httpHeaders["Content-Type"] = contentType
		if let data = data {
			request.httpBody = data
		} else if endpoint.method == .post || endpoint.method == .put || endpoint.method == .patch {
			request.httpBody = try? encoder.encode(parameters)
			httpHeaders["Content-Type"] = "application/json"
		}
		request.allHTTPHeaderFields = httpHeaders
		return request
	}
}

struct NoParameters: Encodable {
	static let none = NoParameters()
}

enum HTTPMethod: String {
	case get = "GET"
	case head = "HEAD"
	case post = "POST"
	case put = "PUT"
	case delete = "DELETE"
	case patch = "PATCH"
}
