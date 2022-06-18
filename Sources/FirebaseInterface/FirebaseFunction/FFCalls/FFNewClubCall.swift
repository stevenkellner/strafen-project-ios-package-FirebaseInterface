//
//  FFNewClubCall.swift
//  
//
//  Created by Steven on 12.06.22.
//

import Foundation

/// Creates a new club with given properties.
/// Doesn't update club, if already a club with same club id exists.
internal struct FFNewClubCall: FFCallable {
        
    static let functionName: String = "newClub"
    
    /// Properties of the club to be created.
    private let clubProperties: FFClubPropertiesParameter
    
    /// Properties of the person creating the club.
    private let personProperties: FFPersonPropertiesWithUserIdParameter
    
    var parameters: FFParameters {
        FFParameter(self.clubProperties, for: "clubProperties")
        FFParameter(self.personProperties, for: "personProperties")
    }
}
