//
//  HttpClientProtocol.swift
//  JsonApiBuddy
//
//  Created by Mikkel Sindberg Eriksen on 17/05/2022.
//

import Foundation

/// A struct representing an error response from an api.
public struct ResponseError<R: JsonDecodable> {

    /// The http status code of the response.
    public let httpStatusCode: Int

    /// The path of the request resulting in the response.
    public let requestPath: String

    /// The deserialized error response body reported by the api.
    public let responseBody: R
}

/// An enum representing the different errors that can be result from performing a request.
public enum HttpClientError<R: Request>: Swift.Error {

    /// The request failed because the api responded with an error.
    case responseError(ResponseError<R.ResponseError>)

    /// The request failed because of a network error.
    case networkError(Swift.Error)

    /// The request failed because it was cancelled.
    case requestCancelled

    /// The request failed because of an internal error, see error message for details.
    case internalError(String)
}

/// A protocol defining an interface for a network client towards a specific api, defined by a base url.
public protocol HttpClientProtocol {

    /// A type defining the result of a request performed by the http client. It will be passed into the completion handler, defined below.
    typealias RequestResult<R: Request> = Result<R.ResponseObject, HttpClientError<R>>

    /// A type defining the completion block, which will be called when performing the request has been resolved.
    typealias Completion<R: Request> = (RequestResult<R>) -> Void

    /// Perform the given request.
    ///
    /// - parameter request: The request for the http client to perform.
    /// - parameter completion: The completion block, which will be executed on the main thread, when the requst has been resolved.
    /// - returns: The session task performing the request. Use this for cancellation etc.
    func perform<R: Request>(request: R, completion: @escaping Completion<R>) -> URLSessionTask?

    /// Perform the given request using swift concurrency.
    ///
    /// - parameter request: The request for the http client to perform.
    /// - throws: Throws a HttpClientError if performing the request fails.
    /// - returns: Returns Request.ResponseObject if performing the request succeeds.
    @available(iOS 13, *)
    func perform<R: Request>(request: R) async throws -> R.ResponseObject
}
