//
//  FFPersonPropertiesWithUserIdParameter.swift
//  
//
//  Created by Steven on 12.06.22.
//

import Foundation
import StrafenProjectTypes

/// Person properties with id, name, sign in date and user id.
public struct FFPersonPropertiesWithUserIdParameter {
    
    /// Id of the person.
    public private(set) var id: Person.ID
    
    /// Sign in date of the person.
    public private(set) var signInDate: Date
    
    /// User id of the person.
    public private(set) var userId: String
    
    /// Name of the person.
    public private(set) var name: FFPersonNameParameter
}

extension FFPersonPropertiesWithUserIdParameter: FFParameterType {
    public var parameter: [String: any FFParameterType] {
        return [
            "id": self.id,
            "signInDate": self.signInDate,
            "userId": self.userId,
            "name": self.name
        ]
    }
}

extension FFPersonPropertiesWithUserIdParameter: Decodable {}
