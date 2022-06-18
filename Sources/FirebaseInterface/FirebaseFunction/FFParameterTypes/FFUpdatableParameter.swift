//
//  FFUpdatableParameter.swift
//  
//
//  Created by Steven on 12.06.22.
//

import Foundation

/// Type that can be updated and stored in the database.
internal struct FFUpdatableParameter<T> {
    
    /// Update properties with timespamp and person id.
    internal struct UpdateProperties {
        
        /// Timestamp of the database update.
        public private(set) var timestamp: Date
        
        /// Id of the person that updates database.
        public private(set) var personId: UUID
    }
    
    /// Property that can be updated.
    public private(set) var property: T
    
    /// Update properties with timespamp and person id.
    public private(set) var updateProperties: UpdateProperties
}

extension FFUpdatableParameter.UpdateProperties: FFParameterType {
    var parameter: [String: any FFParameterType] {
        return [
            "timestamp": self.timestamp,
            "personId": self.personId
        ]
    }
}

extension FFUpdatableParameter.UpdateProperties: Decodable {}

extension FFUpdatableParameter: FFParameterType where T: FFParameterType, T.Parameter == [String: any FFParameterType] {
    var parameter: [String: any FFParameterType] {
        return self.property.parameter.merging([
            "updateProperties": self.updateProperties
        ]) { _, value in value }
    }
}

extension FFUpdatableParameter: Decodable where T: Decodable {
    private enum CodingKeys: String, CodingKey {
        case updateProperties
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.updateProperties = try container.decode(UpdateProperties.self, forKey: .updateProperties)
        self.property = try T(from: decoder)
    }
}
