//
//  FFPersonPropertiesWithIsAdminParameter.swift
//  
//
//  Created by Steven on 12.06.22.
//

import Foundation
import StrafenProjectTypes

/// Person properties with id, name, sign in date and if person is admin.
public struct FFPersonPropertiesWithIsAdminParameter {
    
    /// Id of the person.
    public private(set) var id: Person.ID
    
    /// Sign in date of the person.
    public private(set) var signInDate: Date
    
    /// Indicates whether person is admin.
    public private(set) var isAdmin: Bool
    
    /// Name of the person
    public private(set) var name: FFPersonNameParameter
}

extension FFPersonPropertiesWithIsAdminParameter: FFParameterType {
    public var parameter: [String: any FFParameterType] {
        return [
            "id": self.id,
            "signInDate": self.signInDate,
            "isAdmin": self.isAdmin,
            "name": self.name
        ]
    }
}

extension FFPersonPropertiesWithIsAdminParameter: Decodable {}
