//
//  FFForceSignOutCall.swift
//  
//
//  Created by Steven on 12.06.22.
//

import Foundation

/// Force sign out a person.
internal struct FFForceSignOutCall: FFCallable {
    
    static let functionName: String = "forceSignOut"
    
    /// Id of the club to force sign out the person.
    private let clubId: UUID
    
    /// Id of the person to force sign out.
    private let personId: UUID
    
    var parameters: FFParameters {
        FFParameter(self.clubId, for: "clubId")
        FFParameter(self.personId, for: "personId")
    }
}
