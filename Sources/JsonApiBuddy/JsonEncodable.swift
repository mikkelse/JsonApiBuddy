//
//  JsonEncodable.swift
//  JsonApiBuddy
//
//  Created by Mikkel Sindberg Eriksen on 17/05/2022.
//

import Foundation

/// A protocol defining an interface for encoding an entity to json data.
public protocol JsonEncodable: Encodable {

    /// Encode the entitiy to json data.
    ///
    /// - parameter dateStrategy: The encoding strategy to use for dates. Defaults to .iso8601.
    /// - throws: JSONEncoder errors.
    /// - returns: The entity encoded as json data..
    func jsonEncode(dateStrategy: JSONEncoder.DateEncodingStrategy) throws -> Data
}

public extension JsonEncodable {

    func jsonEncode(dateStrategy: JSONEncoder.DateEncodingStrategy = .iso8601) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = dateStrategy
        return try encoder.encode(self)
    }
}

extension String: JsonEncodable {}
extension Array: JsonEncodable where Element: JsonEncodable {}
extension Dictionary: JsonEncodable where Key: JsonEncodable, Value: JsonEncodable {}
