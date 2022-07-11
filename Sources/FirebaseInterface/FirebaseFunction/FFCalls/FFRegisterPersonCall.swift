//
//  FFRegisterPersonCall.swift
//  
//
//  Created by Steven on 12.06.22.
//

import StrafenProjectTypes

/// Register person to club with given club id.
public struct FFRegisterPersonCall: FFCallable {
    
    public typealias ReturnType = FFClubPropertiesParameter
    
    public static let functionName: String = "registerPerson"
    
    /// Id of the club to change the person.
    public private(set) var clubId: Club.ID
    
    /// Properties of person to register.
    public private(set) var personProperties: FFPersonPropertiesWithUserIdParameter
    
    public var parameters: FFParameters {
        FFParameter(self.clubId, for: "clubId")
        FFParameter(self.personProperties, for: "personProperties")
    }
}
