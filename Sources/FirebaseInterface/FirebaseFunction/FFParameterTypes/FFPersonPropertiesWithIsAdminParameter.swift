//
//  FFPersonPropertiesWithIsAdminParameter.swift
//  
//
//  Created by Steven on 12.06.22.
//

import Foundation

/// Person properties with id, name, sign in date and if person is admin.
internal struct FFPersonPropertiesWithIsAdminParameter {
    
    /// Id of the person.
    public private(set) var id: UUID
    
    /// Sign in date of the person.
    public private(set) var signInDate: Date
    
    /// Indicates whether person is admin.
    public private(set) var isAdmin: Bool
    
    /// Name of the person
    public private(set) var name: FFPersonNameParameter
}

extension FFPersonPropertiesWithIsAdminParameter: FFParameterType {
    var parameter: [String: any FFParameterType] {
        return [
            "id": self.id,
            "signInDate": self.signInDate,
            "isAdmin": self.isAdmin,
            "name": self.name
        ]
    }
}

extension FFPersonPropertiesWithIsAdminParameter: Decodable {}
