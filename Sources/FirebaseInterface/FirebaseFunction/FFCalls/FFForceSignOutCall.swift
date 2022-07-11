//
//  FFForceSignOutCall.swift
//  
//
//  Created by Steven on 12.06.22.
//

import StrafenProjectTypes

/// Force sign out a person.
public struct FFForceSignOutCall: FFCallable {
    
    public static let functionName: String = "forceSignOut"
    
    /// Id of the club to force sign out the person.
    public private(set) var clubId: Club.ID
    
    /// Id of the person to force sign out.
    public private(set) var personId: Person.ID
    
    public var parameters: FFParameters {
        FFParameter(self.clubId, for: "clubId")
        FFParameter(self.personId, for: "personId")
    }
}
