//
//  JsonEncodable.swift
//  JsonApiBuddy
//
//  Created by Mikkel Sindberg Eriksen on 17/05/2022.
//

import Foundation

/// A protocol defining an interface for encoding an entity to json data.
public protocol JsonEncodable: Encodable {
    
    /// The date encoding strategy to use for the encodable.
    ///
    /// The default implementation uses .iso8601. Override implementation for custom formats.
    var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy { get }

    /// Encode the entitiy to json data.
    ///
    /// - throws: JSONEncoder errors.
    /// - returns: The entity encoded as json data..
    func jsonEncode() throws -> Data
}

public extension JsonEncodable {
    
    var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy { .iso8601 }

    func jsonEncode() throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = dateEncodingStrategy
        return try encoder.encode(self)
    }
}

extension String: JsonEncodable {}
extension Array: JsonEncodable where Element: JsonEncodable {}
extension Dictionary: JsonEncodable where Key: JsonEncodable, Value: JsonEncodable {}
