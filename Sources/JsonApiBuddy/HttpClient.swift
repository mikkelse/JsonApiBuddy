//
//  HttpClient.swift
//  JsonApiBuddy
//
//  Created by Mikkel Sindberg Eriksen on 17/05/2022.
//

import Foundation

/// A default implementation of the HttpClientPotocol..
public class HttpClient: HttpClientProtocol {

    private let session: URLSession
    private let baseUrl: URL

    public init(baseUrl: URL, sessionConfiguration: URLSessionConfiguration? = nil) {
        if let configuration = sessionConfiguration {
            self.session = URLSession(configuration: configuration)
        } else {
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 15
            configuration.timeoutIntervalForResource = 30.0
            configuration.httpShouldSetCookies = false
            self.session = URLSession(configuration: configuration)
        }
        self.baseUrl = baseUrl
    }
}

public extension HttpClient {

    func perform<R: Request>(request: R, completion: @escaping Completion<R>) -> URLSessionTask? {
        let task = dataTask(for: request) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        task?.resume()
        return task
    }

    @available(iOS 13.0.0, *) @discardableResult
    func perform<R: Request>(request: R) async throws -> R.ResponseObject {

        let sessionTask = SessionTask()

        return try await withTaskCancellationHandler {
            Task { await sessionTask.cancel() }
        } operation: {
            if Task.isCancelled { throw HttpClientError<R>.requestCancelled }
            return try await withCheckedThrowingContinuation { continuation in
                Task {
                    let task = dataTask(for: request) { result in
                        switch result {
                        case .success(let responseObject):
                            continuation.resume(returning: responseObject)
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                    }
                    guard let task = task else { return }
                    await sessionTask.start(task)
                }
            }
        }
    }
}

extension HttpClient {

    /// Construct an url request from the given api request.
    private func urlRequest<R: Request>(from request: R) throws -> URLRequest {

        let url = try self.url(from: request)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.httpMethod.rawValue

        // Add custom headers for the request.
        for (field, value) in request.headerFields {
            urlRequest.addValue(value, forHTTPHeaderField: field)
        }

        // Add http body for the request.
        do {
            urlRequest.httpBody = try request.httpBody?.jsonEncode()
        } catch {
            throw HttpClientError<R>.internalError("Failed to json encode http body: \(error)")
        }

        return urlRequest
    }

    /// Construct a URL from the given api request.
    private func url<R: Request>(from request: R) throws -> URL {

        var urlComponents = URLComponents()
        urlComponents.scheme = baseUrl.scheme
        urlComponents.queryItems = request.queryItems
        urlComponents.host = baseUrl.host
        urlComponents.path = ([baseUrl.path] + request.pathComponents).joined(separator: "/")

        guard let url = urlComponents.url else {
            throw HttpClientError<R>.internalError("Failed to resolve url from components: \(urlComponents)")
        }
        return url
    }
}

extension HttpClient {

    func dataTask<R: Request>(for request: R, completion: @escaping Completion<R>) -> URLSessionTask? {
        var task: URLSessionTask?
        do {
            let urlRequest = try urlRequest(from: request)
            task = session.dataTask(with: urlRequest) { data, response, error in
                completion(self.handle(data: data, response: response, error: error))
            }
        } catch let error as HttpClientError<R> {
            completion(.failure(error))
        } catch {
            completion(.failure(.internalError("Unexpected error: \(error)")))
        }
        return task
    }

    /// Handle the result of  an URLRequest.
    private func handle<R: Request>(data: Data?, response: URLResponse?, error: Error?) -> RequestResult<R> {

        /// Make sure we do not have a network error.
        if let networkError = error as NSError? {
            if networkError.code == NSURLErrorCancelled {
                return .failure(.requestCancelled)
            }
            return .failure(.networkError(networkError))
        }

        /// Make sure we have a valid http url response.
        guard let httpResponse = response as? HTTPURLResponse else {
            return .failure(.internalError("Expected a HTTPURLResponse, but received a '\(type(of: response.self))'"))
        }

        /// Build debug info.
        let debugInfo = debugInfo(from: httpResponse)

        /// Make sure we have valid data to decode.
        guard let responseData = data else {
            return .failure(.internalError("Missing response data \(debugInfo)"))
        }

        let status = httpResponse.statusCode
        let path = httpResponse.url?.path ?? "?"

        /// Resolve the result of the request  based on the http status code.
        switch status {
        case 200...299:
            do {
                let data = R.ResponseObject.self is EmptyBody.Type ? EmptyBody.jsonData : responseData
                let responseObject = try R.ResponseObject.jsonDecode(json: data)
                return .success(responseObject)
            } catch {
                return .failure(.internalError("Failed to decode response object: \(error) \(debugInfo)"))
            }
        case 400...599:
            do {
                let data = R.ResponseError.self is EmptyBody.Type ? EmptyBody.jsonData : responseData
                let body = try R.ResponseError.jsonDecode(json: data)
                let responseError = ResponseError(httpStatusCode: status, requestPath: path, responseBody: body)
                return .failure(.responseError(responseError))
            } catch {
                return .failure(.internalError("Failed to decode response error: \(error) \(debugInfo)"))
            }
        default:
            return .failure(.internalError("Unexpected http status code \(debugInfo)"))
        }
    }

    private func debugInfo(from response: HTTPURLResponse) -> String {
        return "(PATH: \(response.url?.path ?? "?"), STATUS_CODE: \(response.statusCode))"
    }
}

// See:
// https://stackoverflow.com/questions/69506002/cancelling-an-async-await-network-request
// https://forums.swift.org/t/how-to-use-withtaskcancellationhandler-properly/54341/7
@available(iOS 13.0.0, *)
private actor SessionTask {
    private var sessionTask: URLSessionTask?

    func start(_ task: URLSessionTask) {
        sessionTask = task
        sessionTask?.resume()
    }

     func cancel() {
         sessionTask?.cancel()
     }
 }
