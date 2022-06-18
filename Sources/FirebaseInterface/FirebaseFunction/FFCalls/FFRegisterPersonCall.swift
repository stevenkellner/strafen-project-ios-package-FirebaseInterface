//
//  FFRegisterPersonCall.swift
//  
//
//  Created by Steven on 12.06.22.
//

import Foundation

/// Register person to club with given club id.
internal struct FFRegisterPersonCall: FFCallable {
    
    typealias ResultType = FFClubPropertiesParameter
    
    static let functionName: String = "registerPerson"
    
    /// Id of the club to change the person.
    private let clubId: UUID
    
    /// Properties of person to register.
    private let personProperties: FFPersonPropertiesWithUserIdParameter
    
    var parameters: FFParameters {
        FFParameter(self.clubId, for: "clubId")
        FFParameter(self.personProperties, for: "personProperties")
    }
}
