//
//  JsonDecodable.swift
//  JsonApiBuddy
//
//  Created by Mikkel Sindberg Eriksen on 17/05/2022.
//

import Foundation

/// A protocol defining an internface for decoding an entity from json data.
public protocol JsonDecodable: Decodable {

    /// Decode the entitiy from the given JjsonSON data.
    ///
    /// - parameter data: The json data to decode the entity from.
    /// - parameter dateStrategy: The decoding strategy to use for decoding dates. Defaults to .iso8601.
    /// - throws: JSONDecoder errors.
    /// - returns: The entity decoded from the given json data.
    static func jsonDecode(json data: Data, dateStrategy: JSONDecoder.DateDecodingStrategy) throws -> Self
}

public extension JsonDecodable {

    static func jsonDecode(json data: Data, dateStrategy: JSONDecoder.DateDecodingStrategy = .iso8601) throws -> Self {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = dateStrategy
        return try decoder.decode(Self.self, from: data)
    }
}

extension String: JsonDecodable {}
extension Array: JsonDecodable where Element: JsonDecodable {}
extension Dictionary: JsonDecodable where Key: JsonDecodable, Value: JsonDecodable {}
