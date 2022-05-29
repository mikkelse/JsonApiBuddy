//
//  Request.swift
//  JsonApiBuddy
//
//  Created by Mikkel Sindberg Eriksen on 17/05/2022.
//

import Foundation

/// A protocol defining an interface for an api request.
public protocol Request {

    /// The expected (http body) response object for  the request. The default implementation ignores any http body.
    associatedtype ResponseObject: JsonDecodable

    /// The expected (http body) response error for the request. The default implementation ignores any http body.
    associatedtype ResponseError: JsonDecodable

    /// The http method of the request. The default implementation is .get.
    var httpMethod: HttpMethod { get }

    /// The headers to set for the request. The default implementation is an empty dictionary.
    var headerFields: [String: String] { get }

    /// The individual components making up the path of the request. I.e.: [path, to, resource]. The default implementation is an empty path.
    var pathComponents: [String] { get }

    /// An list of query items to add to the request. The default implementation is an empty list.
    var queryItems: [URLQueryItem] { get }

    /// The optional http body of the request. The default implementation is a nil body.
    var httpBody: JsonEncodable? { get }
}

/// Default implementation for each of the request properties.
public extension Request {
    typealias ResponseObject = EmptyBody
    typealias ResponseError = EmptyBody
    var httpMethod: HttpMethod { .get }
    var headerFields: [String: String] { [:] }
    var pathComponents: [String] { [] }
    var queryItems: [URLQueryItem] { [] }
    var httpBody: JsonEncodable? { nil }
}

/// An enum representing the supported http methods.
public enum HttpMethod: String {

    /// The requst is a GET request.
    case get = "GET"

    /// The requst is a POST request.
    case post = "POST"

    /// The requst is a PUT request.
    case put = "PUT"

    /// The requst is a DELETE request.
    case delete = "DELETE"
}

/// A struct representing an empty http body. 
public struct EmptyBody: JsonDecodable, JsonEncodable {
    static var jsonData: Data {
        return try! Self().jsonEncode()
    }
}
