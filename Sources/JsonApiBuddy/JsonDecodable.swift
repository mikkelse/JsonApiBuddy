//
//  JsonDecodable.swift
//  JsonApiBuddy
//
//  Created by Mikkel Sindberg Eriksen on 17/05/2022.
//

import Foundation

/// A protocol defining an internface for decoding an entity from json data.
public protocol JsonDecodable: Decodable {

    /// The date decding strategy to use for the decodable.
    ///
    /// The default implementation uses .iso8601. Override implementation for custom formats.
    static var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy { get }
    
    /// Decode the entitiy from the given JjsonSON data.
    ///
    /// - parameter data: The json data to decode the entity from.
    /// - throws: JSONDecoder errors.
    /// - returns: The entity decoded from the given json data.
    static func jsonDecode(json data: Data) throws -> Self
}

public extension JsonDecodable {

    static func jsonDecode(json data: Data) throws -> Self {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = dateDecodingStrategy
        return try decoder.decode(Self.self, from: data)
    }
    
    static var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy { .iso8601 }
}

extension String: JsonDecodable {}
extension Array: JsonDecodable where Element: JsonDecodable {}
extension Dictionary: JsonDecodable where Key: JsonDecodable, Value: JsonDecodable {}
