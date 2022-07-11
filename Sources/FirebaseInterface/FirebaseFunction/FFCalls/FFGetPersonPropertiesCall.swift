//
//  FFGetPersonPropertiesCall.swift
//  
//
//  Created by Steven on 12.06.22.
//

import Foundation

/// Returns club and person properties of user id.
public struct FFGetPersonPropertiesCall: FFCallable {
    
    public struct ReturnType: Decodable {
        
        /// Properties of person with specified user id.
        public private(set) var personProperties: FFPersonPropertiesWithIsAdminParameter
        
        /// Properties of club.
        public private(set) var clubProperties: FFClubPropertiesParameter
    }
    
    public static let functionName: String = "getPersonProperties"
    
    /// User id of person to get properties from.
    public private(set) var userId: String
    
    public var parameters: FFParameters {
        FFParameter(self.userId, for: "userId")
    }
}
