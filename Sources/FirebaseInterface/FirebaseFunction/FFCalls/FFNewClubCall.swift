//
//  FFNewClubCall.swift
//  
//
//  Created by Steven on 12.06.22.
//

import Foundation

/// Creates a new club with given properties.
/// Doesn't update club, if already a club with same club id exists.
public struct FFNewClubCall: FFCallable {
        
    public static let functionName: String = "newClub"
    
    /// Properties of the club to be created.
    public private(set) var clubProperties: FFClubPropertiesParameter
    
    /// Properties of the person creating the club.
    public private(set) var personProperties: FFPersonPropertiesWithUserIdParameter
    
    public var parameters: FFParameters {
        FFParameter(self.clubProperties, for: "clubProperties")
        FFParameter(self.personProperties, for: "personProperties")
    }
}
