//
//  FFDeletableParameter.swift
//  
//
//  Created by Steven on 12.06.22.
//

import Foundation

/// Deleted database item or underlying database item
internal enum FFDeletableParameter<T, ID> {
    
    /// Underlying database item.
    case item(T)
    
    /// Deleted database item.
    case deleted(id: ID)
}

extension FFDeletableParameter: FFParameterType where T: FFParameterType, T.Parameter == [String: any FFParameterType], ID: FFParameterType {
    var parameter: [String: any FFParameterType] {
        switch self {
        case .item(let item):
            return item.parameter
        case .deleted(id: let id):
            return [
                "id": id,
                "deleted": true
            ]
        }
    }
}

extension FFDeletableParameter: Decodable where T: Decodable, ID: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id
        case deleted
    }
    
    init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self),
           let deleted = try container.decodeIfPresent(Bool.self, forKey: .deleted),
           deleted {
            let id = try container.decode(ID.self, forKey: .id)
            self = .deleted(id: id)
            return
        }
        
        let item = try T(from: decoder)
        self = .item(item)
    }
}
