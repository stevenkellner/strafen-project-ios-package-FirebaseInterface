//
//  FRDDeleted.swift
//  
//
//  Created by Steven on 03.07.22.
//

import Foundation

/// Deleted type in firebase realtime database.
internal struct FRDDeleted {

    /// Initializes deleted only with `true` deleted parameter.
    /// - Parameter deleted: Deleted parameter has to be `true`.
    public init?(deleted: Bool) {
        if (!deleted) { return nil }
    }

    /// Always true.
    public var deleted: Bool { true }
}

extension FRDDeleted: Decodable {
    private enum CodingKeys: String, CodingKey {
        case deleted
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let deleted = try container.decode(Bool.self, forKey: .deleted)
        guard deleted else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath.appending(CodingKeys.deleted), debugDescription: "Deleted is false."))
        }
    }
}
